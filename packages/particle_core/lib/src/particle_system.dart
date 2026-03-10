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

/// Bundles sampled pixels with the content area they were sampled from.
///
/// [contentArea] is the area in logical pixels² of the actual rendered
/// content (text bounding box or image drawn area). This is used by
/// [ParticleConfig.effectiveParticleCount] to compute density-based count.
class _SampleResult {
  final List<_PixelSample> samples;

  /// Area in logical pixels² of the content that produced these samples.
  /// For text: textWidth × textHeight (the bounding box of the laid-out text).
  /// For images: drawWidth × drawHeight (the aspect-fit area on screen).
  final double contentArea;

  const _SampleResult(this.samples, this.contentArea);
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

  /// Pre-allocated render buffers
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
  ///
  /// Particle count is calculated from the text bounding-box area
  /// and [ParticleConfig.particleDensity]. A larger [ParticleConfig.fontSize]
  /// produces a bigger bounding box, which automatically yields more particles.
  Future<void> setText(String text, Size size) async {
    final result = await _getTextPixels(text, size);
    if (result.samples.isEmpty) return;
    usePerParticleColor = false;
    _applyPixels(result, size, forceReset: false);
  }

  /// Sample [image] and create or re-target particles with per-pixel colors.
  ///
  /// The image is scaled to fit within [size] while preserving aspect ratio.
  /// Particle count is calculated from the drawn image area and density.
  /// Always does a full particle reset since image content is entirely different.
  Future<void> setImage(ui.Image image, Size size) async {
    final result = await _getImagePixels(image, size);
    if (result.samples.isEmpty) return;
    usePerParticleColor = true;
    _applyPixels(result, size, forceReset: true);
  }

  void _applyPixels(_SampleResult result, Size size, {bool forceReset = false}) {
    if (particles.isEmpty || forceReset) {
      _spawnParticles(result, size);
      _allocateBuffers();
    } else {
      // Compute the desired count for the new content. Text changes can
      // produce a very different content area (e.g. "Hi" → "Riverpod"),
      // so particle count must adapt to keep full coverage.
      final densityCount = config.effectiveParticleCount(result.contentArea);
      final targetCount = min(densityCount, result.samples.length);

      // Add/remove particles to match — preserves morph for existing ones.
      if (targetCount != particles.length) {
        _adjustParticleCount(targetCount, size);
        _allocateBuffers();
      }
      _retargetParticles(result.samples);
    }
  }

  /// Run one physics step + notify painter.
  void tick() {
    _updatePhysics();
    _buildRenderData();
    notifyListeners();
  }

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
        // Image mode: per-particle color with particle alpha
        final tc = p.targetColor!;
        int r = (tc >> 16) & 0xFF;
        int g = (tc >> 8) & 0xFF;
        int b = tc & 0xFF;

        // Ensure dark pixels are visible as particles.
        // Very dark colors (luminance < minLum) are boosted proportionally
        // to maintain visibility at small particle sizes while preserving
        // relative hue and saturation.
        final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
        const double minLum = 80;
        if (luminance < minLum && luminance > 0) {
          final scale = minLum / luminance;
          r = (r * scale).round().clamp(0, 255);
          g = (g * scale).round().clamp(0, 255);
          b = (b * scale).round().clamp(0, 255);
        } else if (luminance == 0) {
          // Pure black — assign a visible neutral gray
          r = g = b = minLum.toInt();
        }

        final a = (p.alpha * 255).toInt().clamp(0, 255);
        colors[i] = (a << 24) | (r << 16) | (g << 8) | b;
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

  /// Spawn particles from sampled pixel targets.
  ///
  /// Particle count is determined by:
  /// 1. [ParticleConfig.particleCount] if explicitly set → use that exact count.
  /// 2. Otherwise, [ParticleConfig.particleDensity] × contentArea / 100,000,
  ///    clamped to [[ParticleConfig.minParticleCount], [ParticleConfig.maxParticleCount]].
  ///
  /// The count is also capped at [samples.length] so we never request more
  /// particles than available target positions (each particle needs a pixel
  /// to snap onto). To get more target positions, decrease [ParticleConfig.sampleGap].
  void _spawnParticles(_SampleResult result, Size size) {
    particles.clear();
    final samples = result.samples;

    // Compute density-based count from the content area.
    // effectiveParticleCount handles: explicit particleCount > density calc > clamp.
    final densityCount = config.effectiveParticleCount(result.contentArea);

    // Cap at available sample positions — can't place more particles than
    // target pixels. Users can decrease sampleGap for more targets.
    final count = min(densityCount, samples.length);

    final maxDist = max(size.width, size.height);
    final sizeRange = config.maxParticleSize - config.minParticleSize;
    final alphaRange = config.maxAlpha - config.minAlpha;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // When count < samples.length, evenly stride across ALL sample
    // positions so particles cover the full text uniformly — not just
    // the top-left portion (samples are scanned left→right, top→bottom).
    // e.g. 5000 particles from 15000 samples → take every 3rd sample.
    final bool needsStride = count < samples.length;

    for (int i = 0; i < count; i++) {
      final sampleIdx = needsStride
          ? (i * samples.length) ~/
                count // uniform spread
          : i % samples.length; // wrap when more particles than samples
      final s = samples[sampleIdx];
      final angle = _rng.nextDouble() * pi * 2;
      final dist = _rng.nextDouble() * maxDist;
      particles.add(
        Particle(
          x: cx + cos(angle) * dist,
          y: cy + sin(angle) * dist,
          tx: s.x,
          ty: s.y,
          size: _rng.nextDouble() * sizeRange + config.minParticleSize,
          alpha: _rng.nextDouble() * alphaRange + config.minAlpha,
          targetColor: s.color,
        ),
      );
    }
  }

  /// Add or remove particles to reach [targetCount].
  ///
  /// New particles spawn at random positions around the center and will
  /// animate toward their targets on the next retarget — preserving the
  /// smooth morph effect for existing particles.
  void _adjustParticleCount(int targetCount, Size size) {
    final current = particles.length;
    if (targetCount == current) return;

    if (targetCount > current) {
      // Add more particles at random positions (they'll morph to targets)
      final maxDist = max(size.width, size.height);
      final sizeRange = config.maxParticleSize - config.minParticleSize;
      final alphaRange = config.maxAlpha - config.minAlpha;
      final cx = size.width / 2;
      final cy = size.height / 2;

      for (int i = current; i < targetCount; i++) {
        final angle = _rng.nextDouble() * pi * 2;
        final dist = _rng.nextDouble() * maxDist;
        particles.add(
          Particle(
            x: cx + cos(angle) * dist,
            y: cy + sin(angle) * dist,
            tx: cx,
            ty: cy,
            size: _rng.nextDouble() * sizeRange + config.minParticleSize,
            alpha: _rng.nextDouble() * alphaRange + config.minAlpha,
          ),
        );
      }
    } else {
      // Remove excess particles
      particles.removeRange(targetCount, current);
    }
  }

  /// Retarget existing particles to new sample positions.
  ///
  /// Uses even stride when particles < samples to distribute uniformly
  /// across the full content (same logic as [_spawnParticles]).
  void _retargetParticles(List<_PixelSample> samples) {
    final count = particles.length;
    final needsStride = count < samples.length;

    for (int i = 0; i < count; i++) {
      final sampleIdx = needsStride
          ? (i * samples.length) ~/
                count // uniform spread
          : i % samples.length; // wrap when more particles than samples
      final s = samples[sampleIdx];
      particles[i].tx = s.x;
      particles[i].ty = s.y;
      particles[i].targetColor = s.color;
      particles[i].vx += (_rng.nextDouble() - 0.5) * 6;
      particles[i].vy += (_rng.nextDouble() - 0.5) * 6;
    }
  }

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

  /// Rasterize text and sample opaque pixels as particle targets.
  ///
  /// Returns a [_SampleResult] containing:
  /// - The sampled pixel positions (particle target coordinates).
  /// - The **text bounding-box area** in logical pixels² (`textWidth × textHeight`
  ///   after dividing out devicePixelRatio). This area is used by
  ///   [ParticleConfig.effectiveParticleCount] to compute density-based count.
  ///
  /// Larger [ParticleConfig.fontSize] → bigger bounding box → larger contentArea
  /// → more particles automatically (via density formula).
  Future<_SampleResult> _getTextPixels(String text, Size size) async {
    final dpr = devicePixelRatio;
    final physW = (size.width * dpr).toInt();
    final physH = (size.height * dpr).toInt();
    if (physW == 0 || physH == 0) return const _SampleResult([], 0);

    // Responsive default: scale with widget's shorter dimension so text
    // looks proportional on any screen size.
    //   Mobile  360px  → min(360,800)*0.18  = 64.8 → ~65px
    //   Tablet  768px  → min(768,1024)*0.18 = 138  → ~138px
    //   Desktop 1080px → min(1920,1080)*0.18= 194  → ~194px
    final logicalFontSize = config.fontSize ?? (min(size.width, size.height) * 0.18).clamp(32.0, 200.0);

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

    // Layout with max width for multi-line wrapping
    textPainter.layout(maxWidth: physW.toDouble());

    final textW = textPainter.width;
    final textH = textPainter.height;

    // Content area in logical pixels²: the text bounding box.
    // Dividing physical dimensions by dpr converts to logical pixels.
    // This area drives the density formula:
    //   particleCount = contentArea × particleDensity / 100,000
    final contentArea = (textW / dpr) * (textH / dpr);

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
    if (byteData == null) return const _SampleResult([], 0);

    final Uint8List raw = byteData.buffer.asUint8List();
    final List<_PixelSample> points = [];
    final int gap = max(config.sampleGap, (config.sampleGap * dpr).round());

    for (int y = 0; y < physH; y += gap) {
      for (int x = 0; x < physW; x += gap) {
        final i = (y * physW + x) * 4;
        if (i + 3 < raw.length && raw[i + 3] > 128) {
          points.add(_PixelSample(x / dpr, y / dpr));
        }
      }
    }
    return _SampleResult(points, contentArea);
  }

  /// Read source image pixel data and map positions to fit within widget.
  /// Auto-detects background color by sampling corner pixels.
  ///
  /// Returns a [_SampleResult] containing:
  /// - Sampled pixel positions with per-pixel colors.
  /// - The **drawn image area** in logical pixels² (`drawW × drawH`),
  ///   used by [ParticleConfig.effectiveParticleCount] for density calc.
  Future<_SampleResult> _getImagePixels(
    ui.Image image,
    Size size, {
    Color? skipColor,
  }) async {
    final imgW = image.width;
    final imgH = image.height;
    if (imgW == 0 || imgH == 0) return const _SampleResult([], 0);

    // Read pixel data directly from the source image
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return const _SampleResult([], 0);

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

    // Content area in logical pixels² — the area the image actually
    // occupies on screen after aspect-fit scaling.
    // Used by density formula: count = contentArea × density / 100,000
    final contentArea = drawW * drawH;

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
    return _SampleResult(points, contentArea);
  }

  /// Detect background color by sampling corner and edge pixels.
  /// Returns null if no consistent background found (transparent PNG).
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
