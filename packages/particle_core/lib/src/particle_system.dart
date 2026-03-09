import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'particle.dart';
import 'particle_config.dart';

/// Sampled pixel with position and optional color.
class _PixelSample {
  final double x, y;
  final int? color; // ARGB int, null for text mode

  const _PixelSample(this.x, this.y, [this.color]);
}

/// High-performance particle physics engine.
///
/// Uses [ChangeNotifier] to drive [CustomPainter] repaints
/// without widget tree rebuilds. Renders all particles in a
/// single GPU draw call via [drawRawAtlas].
///
/// Supports both text and image sources.
class ParticleSystem extends ChangeNotifier {
  final ParticleConfig config;
  final List<Particle> particles = [];
  final Random _rng = Random();

  Size screenSize = Size.zero;
  double devicePixelRatio = 1.0;
  Offset pointer = const Offset(-9999, -9999);

  /// Whether particles use per-particle colors (image mode).
  bool usePerParticleColor = false;

  /// Pre-rendered soft circle texture.
  ui.Image? sprite;

  static const int spriteSize = 32;
  static const double _spriteHalf = spriteSize / 2.0;

  // ── Pre-allocated render buffers ──
  Float32List? _transforms;
  Float32List? _srcRects;
  Int32List? _colors;

  ParticleSystem({required this.config});

  /// Initialize the sprite texture.
  Future<void> init() async {
    sprite = await _createSprite();
    _allocateBuffers();
  }

  /// Rasterize [text] and create or re-target particles.
  Future<void> setText(String text, Size size) async {
    final samples = await _getTextPixels(text, size);
    if (samples.isEmpty) return;
    usePerParticleColor = false;
    _applyPixels(samples, size, forceReset: false);
  }

  /// Sample [image] and create or re-target particles with per-pixel colors.
  ///
  /// The image is scaled to fit within [size] while preserving aspect ratio.
  /// Always does a full particle reset since image content is entirely different.
  Future<void> setImage(ui.Image image, Size size) async {
    final samples = await _getImagePixels(image, size);
    if (samples.isEmpty) return;
    usePerParticleColor = true;
    _applyPixels(samples, size, forceReset: true);
  }

  void _applyPixels(List<_PixelSample> samples, Size size, {bool forceReset = false}) {
    if (particles.isEmpty || forceReset) {
      _spawnParticles(samples, size);
      _allocateBuffers();
    } else {
      _retargetParticles(samples);
    }
  }

  /// Run one physics step + notify painter.
  void tick() {
    _updatePhysics();
    _buildRenderData();
    notifyListeners();
  }

  // ── Physics ──────────────────────────────────────────────────────

  void _updatePhysics() {
    final px = pointer.dx;
    final py = pointer.dy;
    final mr = config.mouseRadius;
    final mr2 = mr * mr;
    final rs = config.returnSpeed;
    final rf = config.repelForce;
    final fr = config.friction;

    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];

      final dxT = p.tx - p.x;
      final dyT = p.ty - p.y;
      p.vx += dxT * rs;
      p.vy += dyT * rs;

      final dxM = p.x - px;
      final dyM = p.y - py;
      final dist2 = dxM * dxM + dyM * dyM;
      if (dist2 < mr2 && dist2 > 0.01) {
        final distM = sqrt(dist2);
        final force = (mr - distM) / mr * rf;
        final invDist = 1.0 / distM;
        p.vx += dxM * invDist * force;
        p.vy += dyM * invDist * force;
      }

      p.vx *= fr;
      p.vy *= fr;
      p.x += p.vx;
      p.y += p.vy;
    }
  }

  // ── Render buffer preparation ────────────────────────────────────

  void _allocateBuffers() {
    final n = particles.length;
    if (n == 0) return;
    _transforms = Float32List(n * 4);
    _srcRects = Float32List(n * 4);
    _colors = Int32List(n);

    for (int i = 0; i < n; i++) {
      final j = i * 4;
      _srcRects![j] = 0;
      _srcRects![j + 1] = 0;
      _srcRects![j + 2] = spriteSize.toDouble();
      _srcRects![j + 3] = spriteSize.toDouble();
    }
  }

  void _buildRenderData() {
    final transforms = _transforms;
    final colors = _colors;
    if (transforms == null || colors == null) return;

    // Config color deltas (for text mode)
    final bR = config.particleColor.r;
    final bG = config.particleColor.g;
    final bB = config.particleColor.b;
    final dR = config.displacedColor.r - bR;
    final dG = config.displacedColor.g - bG;
    final dB = config.displacedColor.b - bB;

    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];

      // Transform
      final scale = p.size / _spriteHalf;
      final j = i * 4;
      transforms[j] = scale;
      transforms[j + 1] = 0;
      transforms[j + 2] = p.x - scale * _spriteHalf;
      transforms[j + 3] = p.y - scale * _spriteHalf;

      // Color
      if (p.targetColor != null) {
        // Image mode: use per-particle color with particle alpha
        final tc = p.targetColor!;
        final a = (p.alpha * 255).toInt().clamp(0, 255);
        colors[i] = (a << 24) | (tc & 0x00FFFFFF);
      } else {
        // Text mode: lerp config colors based on displacement
        final dxT = p.tx - p.x;
        final dyT = p.ty - p.y;
        final dist2 = dxT * dxT + dyT * dyT;
        final t = dist2 < 10000.0 ? dist2 / 10000.0 : 1.0;

        final r = ((bR + dR * t) * 255).toInt().clamp(0, 255);
        final g = ((bG + dG * t) * 255).toInt().clamp(0, 255);
        final b = ((bB + dB * t) * 255).toInt().clamp(0, 255);
        final a = (p.alpha * 255).toInt().clamp(0, 255);

        colors[i] = (a << 24) | (r << 16) | (g << 8) | b;
      }
    }
  }

  Float32List? get transforms => _transforms;

  Float32List? get srcRects => _srcRects;

  Int32List? get atlasColors => _colors;

  // ── Particle lifecycle ───────────────────────────────────────────

  void _spawnParticles(List<_PixelSample> samples, Size size) {
    particles.clear();

    // In image mode: one particle per sampled pixel for full coverage,
    // capped at maxParticleCount for performance.
    // In text mode: use density-based count (samples repeat via modulo).
    final count =
        usePerParticleColor ? min(samples.length, config.maxParticleCount) : config.effectiveParticleCount(size);
    final maxDist = max(size.width, size.height);
    final sizeRange = config.maxParticleSize - config.minParticleSize;
    final alphaRange = config.maxAlpha - config.minAlpha;
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 0; i < count; i++) {
      final s = samples[i % samples.length];
      final angle = _rng.nextDouble() * pi * 2;
      final dist = _rng.nextDouble() * maxDist;
      particles.add(Particle(
        x: cx + cos(angle) * dist,
        y: cy + sin(angle) * dist,
        tx: s.x,
        ty: s.y,
        size: _rng.nextDouble() * sizeRange + config.minParticleSize,
        alpha: _rng.nextDouble() * alphaRange + config.minAlpha,
        targetColor: s.color,
      ));
    }
  }

  void _retargetParticles(List<_PixelSample> samples) {
    for (int i = 0; i < particles.length; i++) {
      final s = samples[i % samples.length];
      particles[i].tx = s.x;
      particles[i].ty = s.y;
      particles[i].targetColor = s.color;
      particles[i].vx += (_rng.nextDouble() - 0.5) * 6;
      particles[i].vy += (_rng.nextDouble() - 0.5) * 6;
    }
  }

  // ── Sprite creation ──────────────────────────────────────────────

  static Future<ui.Image> _createSprite() async {
    const s = spriteSize;
    const center = s / 2.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, s.toDouble(), s.toDouble()),
    );

    final paint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(center, center),
        center,
        [
          const Color(0xFFFFFFFF),
          const Color(0xAAFFFFFF),
          const Color(0x00FFFFFF),
        ],
        [0.0, 0.35, 1.0],
      );

    canvas.drawCircle(const Offset(center, center), center, paint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(s, s);
    picture.dispose();
    return image;
  }

  // ── Text rasterization ───────────────────────────────────────────

  Future<List<_PixelSample>> _getTextPixels(String text, Size size) async {
    final dpr = devicePixelRatio;
    final physW = (size.width * dpr).toInt();
    final physH = (size.height * dpr).toInt();
    if (physW == 0 || physH == 0) return [];

    // Use user-provided fontSize, or default to 60
    final logicalFontSize = config.fontSize ?? 60.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFFFFFFFF),
          fontSize: logicalFontSize * dpr,
          fontWeight: config.fontWeight,
          fontFamily: config.fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: config.textAlign,
    );

    // Layout with max width — enables multi-line wrapping
    textPainter.layout(maxWidth: physW.toDouble());

    final textW = textPainter.width;
    final textH = textPainter.height;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, physW.toDouble(), physH.toDouble()),
    );

    // Center the text block
    final offsetX = (physW - textW) / 2;
    final offsetY = (physH - textH) / 2;
    textPainter.paint(canvas, Offset(offsetX, offsetY));

    final picture = recorder.endRecording();
    final image = await picture.toImage(physW, physH);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    picture.dispose();
    if (byteData == null) return [];

    final Uint8List raw = byteData.buffer.asUint8List();
    final List<_PixelSample> points = [];
    final int gap = max(config.sampleGap, (config.sampleGap * dpr).round());

    for (int y = 0; y < physH; y += gap) {
      for (int x = 0; x < physW; x += gap) {
        final i = (y * physW + x) * 4;
        if (i + 3 < raw.length && raw[i + 3] > 128) {
          points.add(_PixelSample(x / dpr, y / dpr)); // no color = text mode
        }
      }
    }
    return points;
  }

  // ── Image rasterization ──────────────────────────────────────────

  /// Read source [image] pixel data directly and map positions
  /// to fit centered within [size].
  ///
  /// Reads the original image bytes to avoid Flutter web DPR issues.
  /// Auto-detects background color by sampling corner pixels.
  Future<List<_PixelSample>> _getImagePixels(
    ui.Image image,
    Size size, {
    Color? skipColor,
  }) async {
    final imgW = image.width;
    final imgH = image.height;
    if (imgW == 0 || imgH == 0) return [];

    // Read pixel data directly from the source image
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return [];

    final raw = byteData.buffer.asUint8List();

    // Determine actual pixel stride from byte data
    int stride = imgW;
    final expectedBytes = imgW * imgH * 4;
    if (raw.length > expectedBytes) {
      stride = raw.length ~/ (imgH * 4);
    }
    final actualH = min(imgH, raw.length ~/ (stride * 4));

    // Auto-detect background color from corner pixels
    final bgColor = skipColor ?? _detectBackgroundColor(raw, stride, imgW, actualH);

    // Compute how the image fits within the widget (centered, aspect-fit)
    final imgAspect = imgW / imgH;
    final widgetAspect = size.width / size.height;

    double drawW, drawH;
    if (imgAspect > widgetAspect) {
      drawW = size.width * 0.85;
      drawH = drawW / imgAspect;
    } else {
      drawH = size.height * 0.85;
      drawW = drawH * imgAspect;
    }

    final offsetX = (size.width - drawW) / 2;
    final offsetY = (size.height - drawH) / 2;

    final scaleX = drawW / imgW;
    final scaleY = drawH / imgH;

    final List<_PixelSample> points = [];
    final int gap = max(1, config.sampleGap);

    // Background matching tolerance (±threshold per channel)
    const int tolerance = 30;
    final int bgR = bgColor != null ? (bgColor.r * 255.0).round().clamp(0, 255) : -1000;
    final int bgG = bgColor != null ? (bgColor.g * 255.0).round().clamp(0, 255) : -1000;
    final int bgB = bgColor != null ? (bgColor.b * 255.0).round().clamp(0, 255) : -1000;

    for (int y = 0; y < actualH; y += gap) {
      for (int x = 0; x < imgW; x += gap) {
        final i = (y * stride + x) * 4;
        if (i + 3 >= raw.length) continue;

        final r = raw[i];
        final g = raw[i + 1];
        final b = raw[i + 2];
        final a = raw[i + 3];

        // Skip transparent pixels
        if (a < 30) continue;

        // Skip background color (auto-detected or user-specified)
        if (bgColor != null &&
            (r - bgR).abs() < tolerance &&
            (g - bgG).abs() < tolerance &&
            (b - bgB).abs() < tolerance) {
          continue;
        }

        final color = (a << 24) | (r << 16) | (g << 8) | b;
        final logX = x * scaleX + offsetX;
        final logY = y * scaleY + offsetY;

        points.add(_PixelSample(logX, logY, color));
      }
    }
    return points;
  }

  /// Sample corner pixels and detect background color.
  /// If 3+ corners share a similar color, returns that color.
  /// Returns null if no consistent background is found (likely transparent PNG).
  static Color? _detectBackgroundColor(
    Uint8List raw,
    int stride,
    int width,
    int height,
  ) {
    if (width < 2 || height < 2) return null;

    // Sample 4 corners + 4 edge midpoints
    final samplePoints = [
      (0, 0),
      (width - 1, 0),
      (0, height - 1),
      (width - 1, height - 1),
      (width ~/ 2, 0),
      (width ~/ 2, height - 1),
      (0, height ~/ 2),
      (width - 1, height ~/ 2),
    ];

    final colors = <(int, int, int, int)>[];
    for (final (x, y) in samplePoints) {
      final i = (y * stride + x) * 4;
      if (i + 3 >= raw.length) continue;
      colors.add((raw[i], raw[i + 1], raw[i + 2], raw[i + 3]));
    }

    if (colors.length < 4) return null;

    // Count how many samples are similar to the first corner
    final ref = colors[0];
    const t = 30;
    int matches = 0;
    for (final c in colors) {
      if ((c.$1 - ref.$1).abs() < t && (c.$2 - ref.$2).abs() < t && (c.$3 - ref.$3).abs() < t) {
        matches++;
      }
    }

    // If majority of samples match, it's the background
    if (matches >= (colors.length * 0.6).ceil()) {
      // If all corners are transparent, no need for color filter
      if (ref.$4 < 30) return null;
      return Color.fromARGB(ref.$4, ref.$1, ref.$2, ref.$3);
    }

    return null;
  }
}
