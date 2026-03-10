import 'package:flutter/material.dart';
import 'package:particle_image/particle_image.dart';

class ExpandedImageDemo extends StatefulWidget {
  const ExpandedImageDemo({super.key});

  @override
  State<ExpandedImageDemo> createState() => _ExpandedImageDemoState();
}

class _ExpandedImageDemoState extends State<ExpandedImageDemo> {
  int _selectedIndex = 0;
  final _assets = ['assets/flutter_logo.png', 'assets/mw_logo.png'];
  final _labels = ['Flutter', 'MindWave'];
  final _configs = [
    const ParticleConfig(particleDensity: 3000, backgroundColor: Color(0xFF050508)),
    const ParticleConfig(particleDensity: 3000, backgroundColor: Color(0xFF050508)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _configs[_selectedIndex].backgroundColor,
      appBar: AppBar(title: const Text('Expanded Image'), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ParticleImage.asset(
              _assets[_selectedIndex],
              key: ValueKey('expanded-$_selectedIndex'),
              config: _configs[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        selectedItemColor: Colors.white.withValues(alpha: 0.9),
        unselectedItemColor: Colors.white.withValues(alpha: 0.3),
        onTap: (i) => setState(() => _selectedIndex = i),
        items: List.generate(
          _labels.length,
          (i) => BottomNavigationBarItem(icon: const Icon(Icons.image), label: _labels[i]),
        ),
      ),
    );
  }
}
