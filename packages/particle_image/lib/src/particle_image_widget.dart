import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:particle_core/particle_core.dart';
import 'package:particle_gpu_core/particle_gpu_core.dart';

/// Renders an image as interactive particles.
///
/// Each particle takes the color of its source pixel, creating
/// a colorful particle representation of the image that scatters
/// on touch/hover.
///
/// ```dart
/// ParticleImage(
///   image: myUiImage,
///   config: ParticleConfig(particleDensity: 2000),
/// )
/// ```
///
/// To load from an asset:
/// ```dart
/// ParticleImage.asset(
///   'assets/logo.png',
///   config: ParticleConfig.cosmic(),
/// )
/// ```
class ParticleImage extends StatefulWidget {
  /// A pre-loaded [ui.Image] to render as particles.
  /// Either [image] or [assetPath] must be provided.
  final ui.Image? image;

  /// Asset path to load an image from (e.g. 'assets/logo.png').
  /// Either [image] or [assetPath] must be provided.
  final String? assetPath;

  /// Configuration for particle behavior and appearance.
  /// Note: [ParticleConfig.particleColor] and [ParticleConfig.displacedColor] are ignored in image mode;
  /// per-pixel colors from the image are used instead.
  final ParticleConfig config;

  /// If true, the widget expands to fill its parent.
  final bool expand;

  /// Called when the image is loaded and particles start forming.
  final VoidCallback? onImageLoaded;

  /// Creates a ParticleImage from a pre-loaded [ui.Image].
  const ParticleImage({
    super.key,
    required this.image,
    this.config = const ParticleConfig(),
    this.expand = true,
    this.onImageLoaded,
  }) : assetPath = null;

  /// Creates a ParticleImage from an asset path.
  const ParticleImage.asset(
    this.assetPath, {
    super.key,
    this.config = const ParticleConfig(),
    this.expand = true,
    this.onImageLoaded,
  }) : image = null;

  @override
  State<ParticleImage> createState() => _ParticleImageState();
}

class _ParticleImageState extends State<ParticleImage> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late IParticleCore _system;
  late CustomPainter _painter;
  bool _initialized = false;
  Size _lastSize = Size.zero;
  ui.Image? _loadedImage;

  @override
  void initState() {
    super.initState();
    _system = ParticleSystem(config: widget.config);
    _painter = ParticlePainter(system: _system, config: widget.config);
    _ticker = createTicker(_onTick)..start();

    if (widget.assetPath != null) {
      _loadAsset(widget.assetPath!);
    }
  }

  @override
  void didUpdateWidget(covariant ParticleImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final configChanged = oldWidget.config != widget.config;

    if (configChanged) {
      _system.dispose();
      _system = ParticleSystem(config: widget.config);
      _painter = ParticlePainter(system: _system, config: widget.config);
      _initialized = false;
      if (_lastSize != Size.zero) {
        _initSystem(_lastSize, MediaQuery.devicePixelRatioOf(context));
      }
      return;
    }

    if (oldWidget.image != widget.image && widget.image != null) {
      _initialized = false;
      if (_lastSize != Size.zero) {
        _initSystem(_lastSize, MediaQuery.devicePixelRatioOf(context));
      }
    }

    if (oldWidget.assetPath != widget.assetPath && widget.assetPath != null) {
      _loadedImage = null;
      _initialized = false;
      _loadAsset(widget.assetPath!);
    }
  }

  Future<void> _loadAsset(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    _loadedImage = frame.image;

    // Force re-init now that image is available
    _initialized = false;
    if (_lastSize != Size.zero) {
      if (mounted) {
        _initSystem(_lastSize, MediaQuery.devicePixelRatioOf(context));
      }
    } else {
      // Size not known yet — setState to trigger build → LayoutBuilder → _initSystem
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _system.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    _system.tick(
      pointer: _system.pointer,
      config: widget.config,
    );
  }

  Future<void> _initSystem(Size size, double dpr) async {
    // Determine which engine to use
    final isGpuCapable = await GPUCapabilityProbe.check();
    final count = widget.config.particleCount ?? 0;
    final useGPU = count > 50000 && isGpuCapable;

    final bool currentIsGpu = _system is ParticleGPUComputeManager;

    if (useGPU != currentIsGpu) {
      // Swap engine
      if (useGPU) {
        final gpuSystem = ParticleGPUComputeManager(
          particleCount: widget.config.particleCount ?? 100000,
          dimension: size,
          config: widget.config,
        );
        _system = gpuSystem;
        _painter = ParticleGPUPainter(system: gpuSystem, config: widget.config);
      } else {
        _system = ParticleSystem(config: widget.config);
        _painter = ParticlePainter(system: _system, config: widget.config);
      }
      _initialized = false;
      if (mounted) setState(() {});
    }

    final sizeChanged = _lastSize != size;
    _lastSize = size;

    if (_system is ParticleSystem) {
      final sys = _system as ParticleSystem;
      sys.screenSize = size;
      sys.devicePixelRatio = dpr;
      if (sys.sprite == null) await sys.init();
    } else if (_system is ParticleGPUComputeManager) {
      final sys = _system as ParticleGPUComputeManager;
      await sys.initialize();
    }

    final image = widget.image ?? _loadedImage;
    if (image == null) return; // asset still loading

    if (_initialized && !sizeChanged) return;
    _initialized = true;

    await _system.setImage(image, size);
    widget.onImageLoaded?.call();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);

    Widget child = LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initSystem(size, dpr);

        return RepaintBoundary(
          child: GestureDetector(
            onPanStart: (d) => _system.pointer = d.localPosition,
            onPanUpdate: (d) => _system.pointer = d.localPosition,
            onPanEnd: (_) => _system.pointer = const Offset(-9999, -9999),
            onPanCancel: () => _system.pointer = const Offset(-9999, -9999),
            child: MouseRegion(
              onHover: (e) => _system.pointer = e.localPosition,
              onExit: (_) => _system.pointer = const Offset(-9999, -9999),
              cursor: SystemMouseCursors.basic,
              child: CustomPaint(
                size: size,
                painter: _painter,
                willChange: true,
              ),
            ),
          ),
        );
      },
    );

    if (widget.expand) {
      child = SizedBox.expand(child: child);
    }

    return child;
  }
}
