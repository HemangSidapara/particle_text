import 'package:flutter/material.dart';
import 'package:particle_text/particle_text.dart';

class SizedBoxTextDemo extends StatelessWidget {
  const SizedBoxTextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A10),
      appBar: AppBar(
        title: const Text('SizedBox Text'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card('Fixed 400×200', 400, 200, 'Hello', ParticleConfig.cosmic()),
            const SizedBox(height: 32),
            _card('Fixed 300×150', 300, 150, 'Fire', ParticleConfig.fire()),
            const SizedBox(height: 32),
            _card('Fixed 250×120', 250, 120, 'Mini', ParticleConfig.matrix()),
          ],
        ),
      ),
    );
  }

  Widget _card(String label, double w, double h, String text, ParticleConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: w,
              height: h,
              child: ParticleText(text: text, expand: false, config: config),
            ),
          ),
        ),
      ],
    );
  }
}
