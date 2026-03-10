import 'package:flutter/material.dart';
import 'package:particle_text/particle_text.dart';
import '../shared/widgets.dart';

class CustomColorsDemo extends StatefulWidget {
  const CustomColorsDemo({super.key});

  @override
  State<CustomColorsDemo> createState() => _CustomColorsDemoState();
}

class _CustomColorsDemoState extends State<CustomColorsDemo> {
  double _fontSize = 90;
  double _hue = 220;
  double _brightness = 0.02;
  double _repelForce = 8;
  double _returnSpeed = 0.04;

  ParticleConfig _buildConfig() {
    final base = HSLColor.fromAHSL(1, _hue, 0.5, 0.55).toColor();
    final displaced = HSLColor.fromAHSL(1, _hue, 0.4, 0.85).toColor();
    final glow = HSLColor.fromAHSL(1, _hue, 0.5, 0.75).toColor();
    final bg = Color.from(alpha: 1, red: _brightness, green: _brightness, blue: _brightness + 0.02);

    return ParticleConfig(
      particleColor: base,
      displacedColor: displaced,
      pointerGlowColor: glow,
      backgroundColor: bg,
      repelForce: _repelForce,
      returnSpeed: _returnSpeed,
      fontSize: _fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _buildConfig();
    return Scaffold(
      backgroundColor: config.backgroundColor,
      appBar: AppBar(title: const Text('Custom Colors'), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ParticleText(text: 'Color', config: config),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: Column(
              children: [
                buildSlider('Hue', _hue, 0, 360, (v) => setState(() => _hue = v), Colors.white),
                buildSlider('Background', _brightness, 0, 0.15, (v) => setState(() => _brightness = v), Colors.white),
                buildSlider('Repel Force', _repelForce, 1, 20, (v) => setState(() => _repelForce = v), Colors.white),
                buildSlider(
                  'Return Speed',
                  _returnSpeed,
                  0.01,
                  0.1,
                  (v) => setState(() => _returnSpeed = v),
                  Colors.white,
                ),
                buildSlider('Font Size', _fontSize, 40, 512, (v) => setState(() => _fontSize = v), Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
