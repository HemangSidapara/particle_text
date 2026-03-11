import 'dart:async';
import 'dart:math' as Math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:particle_core/particle_core.dart';

/// The core class for GPU-accelerated particle computing.
class ParticleGPUComputeManager extends IParticleCore {
  final int particleCount;
  final ParticleConfig config;

  ui.Image? _dataFront;
  ui.Image? _dataBack;
  ui.Image? _targetData;

  bool _initialized = false;
  bool _isInitializing = false;

  // CPU Cache for transforms (to support drawRawAtlas in POC)
  Float32List? _transforms;
  Float32List? _srcRects;
  Int32List? _colors;
  Float32List? _velocities;
  Float32List? _targets;
  ui.Image? _sprite;
  double _pocDrift = 0;

  @override
  ui.Offset get pointer => _pointer;
  @override
  set pointer(ui.Offset value) {
    _pointer = value;
    notifyListeners();
  }

  ui.Offset _pointer = const ui.Offset(-9999, -9999);

  @override
  ui.Size screenSize = ui.Size.zero;

  @override
  double devicePixelRatio = 1.0;

  ParticleGPUComputeManager({
    required this.particleCount,
    required ui.Size dimension,
    required this.config,
  }) {
    screenSize = dimension;
  }

  Future<void> initialize() async {
    if (_initialized || _isInitializing) return;
    _isInitializing = true;

    print('GPU: Starting GPGPU initialization for $particleCount particles...');
    try {

      const texSize = 512;
      final initialBytes = Uint8List(texSize * texSize * 4);
      
      // Initialize particles in a grid
      for (int i = 0; i < texSize * texSize; i++) {
        final x = (i % texSize) / texSize * 255;
        final y = (i ~/ texSize) / texSize * 255;
        initialBytes[i * 4] = x.toInt();
        initialBytes[i * 4 + 1] = y.toInt();
        initialBytes[i * 4 + 2] = 127; 
        initialBytes[i * 4 + 3] = 255; // Alpha/Full opacity
      }

      _dataFront = await _createImageFromBytes(initialBytes, texSize, texSize);
      _dataBack = await _createImageFromBytes(initialBytes, texSize, texSize);
      _targetData = await _createImageFromBytes(initialBytes, texSize, texSize);

      await _initCpuCaches();
      
      _initialized = true;
      _isInitializing = false;
      notifyListeners();
    } catch (e, stack) {
      _isInitializing = false;
      print('GPU ERROR: Initialization failed: $e');
      print(stack);
    }
  }

  Future<ui.Image> _createImageFromBytes(Uint8List bytes, int width, int height) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image image) {
        completer.complete(image);
      },
    );
    return completer.future;
  }

  Future<void> _initCpuCaches() async {
    // 1. Create a simple white dot sprite
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawCircle(const ui.Offset(4, 4), 3, ui.Paint()..color = ui.Color(0xFFFFFFFF));
    final picture = recorder.endRecording();
    _sprite = await picture.toImage(8, 8);

    // 2. Initialize 100,000 particle transforms
    _transforms = Float32List(particleCount * 4);
    _srcRects = Float32List(particleCount * 4);
    _colors = Int32List(particleCount);
    _velocities = Float32List(particleCount * 2);
    _targets = Float32List(particleCount * 2);

    for (int i = 0; i < particleCount; i++) {
        _srcRects![i * 4 + 0] = 0;
        _srcRects![i * 4 + 1] = 0;
        _srcRects![i * 4 + 2] = 8;
        _srcRects![i * 4 + 3] = 8;
        _colors![i] = config.particleColor.value;
        
        // Random layout initially
        _transforms![i * 4 + 0] = 1.0; // scale
        _transforms![i * 4 + 1] = 0.0; // skew
        _transforms![i * 4 + 2] = (i % 300) * (screenSize.width / 300); // x
        _transforms![i * 4 + 3] = (i ~/ 300) * (screenSize.height / (particleCount / 300)); // y
    }
  }

  @override
  void tick({required ui.Offset pointer, required ParticleConfig config}) {
    if (!_initialized || _transforms == null || _velocities == null || _targets == null) return;
    
    final px = pointer.dx;
    final py = pointer.dy;
    final mr = config.mouseRadius;
    final mr2 = mr * mr;
    final rs = config.returnSpeed;
    final rf = config.repelForce;
    final fr = config.friction;

    for (int i = 0; i < particleCount; i++) {
        final i2 = i * 2;
        final i4 = i * 4;

        // Current Position
        double x = _transforms![i4 + 2];
        double y = _transforms![i4 + 3];
        
        // Velocity
        double vx = _velocities![i2 + 0];
        double vy = _velocities![i2 + 1];

        // Target Attraction
        final dxT = _targets![i2 + 0] - x;
        final dyT = _targets![i2 + 1] - y;
        vx += dxT * rs;
        vy += dyT * rs;

        // Mouse Repulsion
        final dxM = x - px;
        final dyM = y - py;
        final dist2 = dxM * dxM + dyM * dyM;
        if (dist2 < mr2 && dist2 > 0.01) {
            final distM = Math.sqrt(dist2);
            final force = (mr - distM) / mr * rf;
            final invDist = 1.0 / distM;
            vx += dxM * invDist * force;
            vy += dyM * invDist * force;
        }

        // Friction & Update
        vx *= fr;
        vy *= fr;
        x += vx;
        y += vy;

        // Store back
        _velocities![i2 + 0] = vx;
        _velocities![i2 + 1] = vy;
        _transforms![i4 + 2] = x;
        _transforms![i4 + 3] = y;
    }
    
    _pocDrift += 0.005;
    notifyListeners();
  }

  double get pocDrift => _pocDrift;

  @override
  Future<void> setText(String text, ui.Size size) async {
    if (!_initialized) await initialize();
    
    // 1. Rasterize text to sample points
    final tp = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        fontSize: config.fontSize,
        fontWeight: ui.FontWeight.bold,
    ))
    ..pushStyle(ui.TextStyle(color: const ui.Color(0xFFFFFFFF)))
    ..addText(text);
    
    final paragraph = tp.build()..layout(ui.ParagraphConstraints(width: size.width));
    
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawParagraph(paragraph, ui.Offset(0, (size.height - paragraph.height) / 2));
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    
    if (data == null || _transforms == null) return;

    // 2. Sample valid points (where alpha > 128)
    final points = <ui.Offset>[];
    final bytes = data.buffer.asUint8List();
    final width = img.width;
    final height = img.height;
    const step = 2; // sample every 2nd pixel for speed
    
    for (int y = 0; y < height; y += step) {
      for (int x = 0; x < width; x += step) {
        final idx = (y * width + x) * 4;
        if (idx + 3 < bytes.length && bytes[idx + 3] > 128) {
          points.add(ui.Offset(x.toDouble(), y.toDouble()));
        }
      }
    }

    if (points.isEmpty) return;

    // 3. Map 100,000 particles to these points with scatter targets
    final random = Math.Random();
    for (int i = 0; i < particleCount; i++) {
        final p = points[i % points.length];
        // Jitter the TARGETS to create a beautiful cloud effect
        final jitterX = (random.nextDouble() - 0.5) * 8.0;
        final jitterY = (random.nextDouble() - 0.5) * 8.0;
        
        _targets![i * 2 + 0] = p.dx + jitterX;
        _targets![i * 2 + 1] = p.dy + jitterY;
        
        // If they were just initialized, snap them to targets or scatter them
        if (_transforms![i * 4 + 2] == 0) {
           _transforms![i * 4 + 2] = p.dx + jitterX;
           _transforms![i * 4 + 3] = p.dy + jitterY;
        }
    }
    
    notifyListeners();
  }

  @override
  Future<void> setImage(ui.Image image, ui.Size size) async {
    if (!_initialized) await initialize();
    notifyListeners();
  }

  @override
  Float32List? get transforms => _transforms;

  @override
  Float32List? get srcRects => _srcRects;

  @override
  Int32List? get atlasColors => _colors;

  @override
  ui.Image? get sprite => _sprite;

  ui.Image? get currentData => _dataFront;

  @override
  void dispose() {
    _dataFront?.dispose();
    _dataBack?.dispose();
    _targetData?.dispose();
    super.dispose();
  }
}
