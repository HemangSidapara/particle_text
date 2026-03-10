import 'dart:async';
import 'package:flutter/material.dart';
import 'package:particle_text/particle_text.dart';
import '../shared/widgets.dart';

class TextPerformanceDemo extends StatefulWidget {
  const TextPerformanceDemo({super.key});

  @override
  State<TextPerformanceDemo> createState() => _TextPerformanceDemoState();
}

class _TextPerformanceDemoState extends State<TextPerformanceDemo> {
  double _density = 2000;
  double _fontSize = 60.0;
  int _frameCount = 0;
  double _fps = 0;
  late Timer _fpsTimer;
  DateTime _lastTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastTime).inMilliseconds;
      if (elapsed > 0) {
        setState(() {
          _fps = (_frameCount * 1000.0 / elapsed);
          _frameCount = 0;
          _lastTime = now;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback(_countFrame);
  }

  void _countFrame(Duration _) {
    _frameCount++;
    if (mounted) WidgetsBinding.instance.addPostFrameCallback(_countFrame);
  }

  @override
  void dispose() {
    _fpsTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final effectiveCount = ParticleConfig(
      particleDensity: _density,
      fontSize: _fontSize,
    ).effectiveParticleCount(size.width * size.height);

    return Scaffold(
      backgroundColor: const Color(0xFF020308),
      appBar: AppBar(title: const Text('Text Performance'), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ParticleText(
                  text: 'FPS',
                  config: ParticleConfig(particleDensity: _density, fontSize: _fontSize, drawBackground: false),
                ),
                buildFpsOverlay(_fps),
              ],
            ),
          ),
          buildPerfControls(
            density: _density,
            fontSize: _fontSize,
            effectiveCount: effectiveCount,
            onDensityChanged: (v) => setState(() => _density = v),
            onFontSizeChanged: (v) => setState(() => _fontSize = v),
          ),
        ],
      ),
    );
  }
}
