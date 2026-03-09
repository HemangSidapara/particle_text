import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:particle_core/particle_core.dart';

/// An interactive particle text effect widget.
///
/// Renders thousands of particles that form the given [text].
/// Particles scatter when the user touches or hovers with a pointer,
/// then spring back into the text shape.
///
/// All particles are rendered in a single GPU draw call using
/// [Canvas.drawRawAtlas], making it capable of handling 10,000+
/// particles at 60fps.
///
/// ```dart
/// ParticleText(
///   text: 'Hello',
///   config: ParticleConfig(
///     particleCount: 6000,
///     particleColor: Color(0xFF8CAADE),
///   ),
/// )
/// ```
class ParticleText extends StatefulWidget {
  /// The text to render as particles.
  final String text;

  /// Configuration for particle behavior and appearance.
  final ParticleConfig config;

  /// If true, the widget expands to fill its parent.
  final bool expand;

  /// Called when the text changes and particles begin morphing.
  final VoidCallback? onTextChanged;

  const ParticleText({
    super.key,
    required this.text,
    this.config = const ParticleConfig(),
    this.expand = true,
    this.onTextChanged,
  });

  @override
  State<ParticleText> createState() => _ParticleTextState();
}

class _ParticleTextState extends State<ParticleText> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late ParticleSystem _system;
  late ParticlePainter _painter;
  bool _initialized = false;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _system = ParticleSystem(config: widget.config);
    _painter = ParticlePainter(system: _system, config: widget.config);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant ParticleText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final configChanged = oldWidget.config != widget.config;
    final textChanged = oldWidget.text != widget.text;

    if (configChanged) {
      // Config changed — rebuild the entire system
      _system.dispose();
      _system = ParticleSystem(config: widget.config);
      _painter = ParticlePainter(system: _system, config: widget.config);
      _initialized = false;
      if (_lastSize != Size.zero) {
        _initSystem(_lastSize, MediaQuery.devicePixelRatioOf(context));
      }
    } else if (textChanged && _lastSize != Size.zero) {
      // Only text changed — retarget existing particles (smooth morph)
      _system.setText(widget.text, _lastSize);
      widget.onTextChanged?.call();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _system.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    // Drives physics → builds render data → notifyListeners → painter repaints
    // NO setState — only the CustomPaint canvas repaints
    _system.tick();
  }

  Future<void> _initSystem(Size size, double dpr) async {
    if (_initialized && _lastSize == size) return;
    _initialized = true;
    _lastSize = size;
    _system.screenSize = size;
    _system.devicePixelRatio = dpr;

    // Create sprite texture (once)
    if (_system.sprite == null) {
      await _system.init();
    }

    await _system.setText(widget.text, size);
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
              cursor: SystemMouseCursors.none,
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
