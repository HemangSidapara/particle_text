import 'dart:async';
import 'package:flutter/material.dart';
import 'package:particle_image/particle_image.dart';
import '../shared/widgets.dart';

class ImagePerformanceDemo extends StatefulWidget {
  const ImagePerformanceDemo({super.key});

  @override
  State<ImagePerformanceDemo> createState() => _ImagePerformanceDemoState();
}

class _ImagePerformanceDemoState extends State<ImagePerformanceDemo> {
  double _density = 3000;
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
    ).effectiveParticleCount(size.width * size.height * 0.7);

    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      appBar: AppBar(title: const Text('Image Performance'), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ParticleImage.asset(
                  'assets/flutter_logo.png',
                  key: ValueKey('perf-$_density'),
                  config: ParticleConfig(particleDensity: _density, backgroundColor: const Color(0xFF050508)),
                ),
                buildFpsOverlay(_fps),
              ],
            ),
          ),
          buildPerfControls(
            density: _density,
            effectiveCount: effectiveCount,
            onDensityChanged: (v) => setState(() => _density = v),
          ),
        ],
      ),
    );
  }
}
