import 'package:flutter/material.dart';
import 'package:particle_text/particle_text.dart';

class GpuStressTestDemo extends StatefulWidget {
  const GpuStressTestDemo({super.key});

  @override
  State<GpuStressTestDemo> createState() => _GpuStressTestDemoState();
}

class _GpuStressTestDemoState extends State<GpuStressTestDemo> {
  int _particleCount = 10000;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020308),
      appBar: AppBar(
        title: const Text('GPU Stress Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ParticleText(
                  key: ValueKey(_particleCount), // Force re-init when count changes
                  text: _particleCount >= 100000 ? 'STRESS TEST' : '10K',
                  config: ParticleConfig(
                    particleCount: _particleCount,
                    fontSize: 250,
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Particles: ${_particleCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _particleCount > 50000 ? 'Mode: GPU Compute' : 'Mode: CPU (Classic)',
                          style: TextStyle(
                            color: _particleCount > 50000 ? Colors.greenAccent : Colors.blueAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF0A0A15),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildButton(10000, '10,000 (CPU)'),
                _buildButton(60000, '60,000 (GPU)'),
                _buildButton(100000, '100,000 (GPU)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(int count, String label) {
    final active = _particleCount == count;
    return ElevatedButton(
      onPressed: () => setState(() => _particleCount = count),
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? Colors.white : Colors.white10,
        foregroundColor: active ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }
}
