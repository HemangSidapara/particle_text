import 'package:flutter/material.dart';
import 'package:particle_text/particle_text.dart';

class SplashDemo extends StatefulWidget {
  const SplashDemo({super.key});

  @override
  State<SplashDemo> createState() => _SplashDemoState();
}

class _SplashDemoState extends State<SplashDemo> {
  bool _showSplash = true;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _opacity = 0.0);
    });
  }

  void _onFadeComplete() {
    if (_opacity == 0.0 && mounted) setState(() => _showSplash = false);
  }

  void _restart() {
    setState(() {
      _showSplash = true;
      _opacity = 1.0;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _opacity = 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A10),
        appBar: AppBar(title: const Text('My App'), backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.white.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('App loaded!', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 20)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.replay),
                label: const Text('Replay Splash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Back to demos', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020308),
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 800),
        onEnd: _onFadeComplete,
        child: Stack(
          children: [
            ParticleText(
              text: 'MyApp',
              config: const ParticleConfig(
                particleDensity: 2500,
                particleColor: Color(0xFF6E8FCC),
                displacedColor: Color(0xFFB0C8FF),
                backgroundColor: Color(0xFF020308),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Loading...',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13, letterSpacing: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
