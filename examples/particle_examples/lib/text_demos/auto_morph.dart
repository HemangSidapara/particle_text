import 'dart:async';
import 'package:flutter/material.dart';
import 'package:particle_text/particle_text.dart';

class AutoMorphDemo extends StatefulWidget {
  const AutoMorphDemo({super.key});

  @override
  State<AutoMorphDemo> createState() => _AutoMorphDemoState();
}

class _AutoMorphDemoState extends State<AutoMorphDemo> {
  final _words = ['Flutter', 'Dart', 'Particle', 'Provider', 'BLoC', 'Riverpod', 'GetX', 'Kotlin', 'Swift'];
  int _index = 0;
  late Timer _timer;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_paused) setState(() => _index = (_index + 1) % _words.length);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060F),
      body: Stack(
        children: [
          ParticleText(
            text: _words[_index],
            config: ParticleConfig.cosmic(fontSize: 160.0),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.3)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_words.length, (i) {
                    return Container(
                      width: i == _index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i == _index ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.15),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _paused = !_paused),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _paused ? Icons.play_arrow : Icons.pause,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _paused ? 'Resume' : 'Auto-morphing',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
