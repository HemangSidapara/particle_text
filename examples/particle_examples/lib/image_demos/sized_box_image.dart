import 'package:flutter/material.dart';
import 'package:particle_image/particle_image.dart';

class SizedBoxImageDemo extends StatelessWidget {
  const SizedBoxImageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A10),
      appBar: AppBar(title: const Text('SizedBox Image'), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Flutter Logo — 400×250'),
            const SizedBox(height: 8),
            Center(
              child: _card(
                400,
                250,
                ParticleImage.asset(
                  'assets/flutter_logo.png',
                  config: const ParticleConfig(particleDensity: 3000, backgroundColor: Color(0xFF0A0A10)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _label('MindWave Logo — 350×180'),
            const SizedBox(height: 8),
            Center(
              child: _card(
                350,
                180,
                ParticleImage.asset(
                  'assets/mw_logo.png',
                  config: const ParticleConfig(particleDensity: 3000, backgroundColor: Color(0xFF0A0A10)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _label('Light background — 400×250'),
            const SizedBox(height: 8),
            Center(
              child: _card(
                400,
                250,
                ParticleImage.asset(
                  'assets/flutter_logo.png',
                  config: const ParticleConfig(
                    particleDensity: 3000,
                    drawBackground: true,
                    backgroundColor: Colors.white,
                    showPointerGlow: false,
                  ),
                ),
                borderColor: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, letterSpacing: 1));
  }

  Widget _card(double w, double h, Widget child, {Color? borderColor}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? Colors.white.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(width: w, height: h, child: child),
    );
  }
}
