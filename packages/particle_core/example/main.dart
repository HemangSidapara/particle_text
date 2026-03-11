// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:particle_core/particle_core.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFF020308),
        body: CustomParticleWidget(text: 'Hello'),
      ),
    );
  }
}

/// Example: Building a custom particle widget using particle_core directly.
class CustomParticleWidget extends StatefulWidget {
  final String text;

  const CustomParticleWidget({super.key, required this.text});

  @override
  State<CustomParticleWidget> createState() => _CustomParticleWidgetState();
}

class _CustomParticleWidgetState extends State<CustomParticleWidget> with SingleTickerProviderStateMixin {
  late final ParticleSystem _system;
  late final ParticlePainter _painter;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _system = ParticleSystem(config: ParticleConfig.cosmic());
    _painter = ParticlePainter(system: _system, config: ParticleConfig.cosmic());
    _ticker = createTicker((_) => _system.tick(pointer: _system.pointer, config: _system.config))..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _system.dispose();
    super.dispose();
  }

  Future<void> _init(Size size, double dpr) async {
    if (_system.sprite != null) return;
    _system.screenSize = size;
    _system.devicePixelRatio = dpr;
    await _system.init();
    await _system.setText(widget.text, size);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _init(size, MediaQuery.of(context).devicePixelRatio);
        return GestureDetector(
          onPanUpdate: (d) => _system.pointer = d.localPosition,
          onPanEnd: (_) => _system.pointer = const Offset(-9999, -9999),
          child: CustomPaint(size: size, painter: _painter),
        );
      },
    );
  }
}
