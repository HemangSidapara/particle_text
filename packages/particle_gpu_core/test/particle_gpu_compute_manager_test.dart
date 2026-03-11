import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:particle_gpu_core/particle_gpu_core.dart';
import 'package:particle_core/particle_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ParticleGPUComputeManager', () {
    late ParticleGPUComputeManager manager;
    const config = ParticleConfig(particleCount: 1000);
    const size = Size(800, 600);

    setUp(() {
      manager = ParticleGPUComputeManager(
        particleCount: 1000,
        dimension: size,
        config: config,
      );
    });

    test('initializes with correct properties', () {
      expect(manager.particleCount, 1000);
      expect(manager.screenSize, size);
      expect(manager.config, config);
    });

    test('pointer starts at sentinel value', () {
      expect(manager.pointer.dx, -9999);
      expect(manager.pointer.dy, -9999);
    });

    test('setter updates pointer and notifies listeners', () {
      bool notified = false;
      manager.addListener(() => notified = true);
      
      manager.pointer = const Offset(100, 100);
      
      expect(manager.pointer, const Offset(100, 100));
      expect(notified, isTrue);
    });

    test('dispose clears resources', () {
      // Verify dispose doesn't throw
      manager.dispose();
    });
  });
}
