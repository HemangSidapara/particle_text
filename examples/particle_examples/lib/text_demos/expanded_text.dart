import 'package:flutter/material.dart';
import 'package:particle_text/particle_text.dart';

class ExpandedTextDemo extends StatefulWidget {
  const ExpandedTextDemo({super.key});

  @override
  State<ExpandedTextDemo> createState() => _ExpandedTextDemoState();
}

class _ExpandedTextDemoState extends State<ExpandedTextDemo> {
  String _text = 'Expand';
  int _selectedIndex = 0;

  final _configs = [ParticleConfig.cosmic(), ParticleConfig.fire(), ParticleConfig.pastel()];
  final _labels = ['Cosmic', 'Fire', 'Pastel'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _configs[_selectedIndex].backgroundColor,
      appBar: AppBar(
        title: const Text('Expanded Text'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('Text:', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _text,
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) setState(() => _text = val.trim());
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ParticleText(text: _text, config: _configs[_selectedIndex]),
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
          (i) => BottomNavigationBarItem(icon: const Icon(Icons.auto_awesome), label: _labels[i]),
        ),
      ),
    );
  }
}
