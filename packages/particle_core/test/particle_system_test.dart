import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:particle_core/particle_core.dart';

void main() {
  group('ParticleSystem', () {
    late ParticleSystem system;

    setUp(() {
      system = ParticleSystem(config: const ParticleConfig(particleCount: 100));
      system.devicePixelRatio = 1.0;
    });

    tearDown(() {
      system.dispose();
    });

    test('starts with empty particles', () {
      expect(system.particles, isEmpty);
    });

    test('init creates sprite texture', () async {
      await system.init();
      expect(system.sprite, isNotNull);
    });

    test('setText generates correct number of particles', () async {
      await system.init();
      const size = Size(400, 300);
      system.screenSize = size;
      await system.setText('Hi', size);
      expect(system.particles.length, 100);
    });

    test('setText allocates render buffers', () async {
      await system.init();
      const size = Size(400, 300);
      system.screenSize = size;
      await system.setText('Hi', size);

      expect(system.transforms, isNotNull);
      expect(system.transforms!.length, 100 * 4);
      expect(system.srcRects, isNotNull);
      expect(system.srcRects!.length, 100 * 4);
      expect(system.atlasColors, isNotNull);
      expect(system.atlasColors!.length, 100);
    });

    test('particles have valid target positions', () async {
      await system.init();
      const size = Size(400, 300);
      system.screenSize = size;
      await system.setText('AB', size);

      for (final p in system.particles) {
        expect(p.tx, greaterThanOrEqualTo(0));
        expect(p.ty, greaterThanOrEqualTo(0));
        expect(p.tx, lessThanOrEqualTo(400));
        expect(p.ty, lessThanOrEqualTo(300));
        expect(p.size, greaterThan(0));
        expect(p.alpha, greaterThanOrEqualTo(0.5));
        expect(p.alpha, lessThanOrEqualTo(1.0));
      }
    });

    test('tick moves particles toward targets', () async {
      await system.init();
      const size = Size(400, 300);
      system.screenSize = size;
      await system.setText('X', size);

      final initialDistances = system.particles.map((p) {
        final dx = p.tx - p.x;
        final dy = p.ty - p.y;
        return dx * dx + dy * dy;
      }).toList();

      system.pointer = const Offset(-9999, -9999);
      for (int i = 0; i < 60; i++) {
        system.tick(pointer: system.pointer, config: system.config);
      }

      for (int i = 0; i < system.particles.length; i++) {
        final p = system.particles[i];
        final dx = p.tx - p.x;
        final dy = p.ty - p.y;
        final currentDist = dx * dx + dy * dy;
        expect(currentDist, lessThan(initialDistances[i]), reason: 'Particle $i should be closer to target after tick');
      }
    });

    test('pointer repels nearby particles', () async {
      await system.init();
      const size = Size(400, 300);
      system.screenSize = size;
      await system.setText('O', size);

      system.pointer = const Offset(-9999, -9999);
      for (int i = 0; i < 120; i++) {
        system.tick(pointer: system.pointer, config: system.config);
      }

      final p = system.particles.first;
      p.vx = 0;
      p.vy = 0;
      final beforeX = p.x;
      final beforeY = p.y;

      system.pointer = Offset(p.x + 5, p.y + 5);
      system.tick(pointer: system.pointer, config: system.config);

      final displaced = (p.x - beforeX).abs() > 0.001 || (p.y - beforeY).abs() > 0.001;
      expect(displaced, isTrue, reason: 'Particle should be repelled by nearby pointer');
    });

    test('setText retargets existing particles without changing count', () async {
      await system.init();
      const size = Size(400, 300);
      system.screenSize = size;
      await system.setText('A', size);
      expect(system.particles.length, 100);

      await system.setText('B', size);
      expect(system.particles.length, 100);
    });

    test('empty text does not crash', () async {
      await system.init();
      const size = Size(400, 300);
      system.screenSize = size;
      await system.setText('', size);
      expect(system.particles, isEmpty);
    });

    test('zero-size canvas does not crash', () async {
      await system.init();
      const size = Size(0, 0);
      system.screenSize = size;
      await system.setText('Test', size);
      expect(system.particles, isEmpty);
    });

    test('respects config particle count', () async {
      final customSystem = ParticleSystem(
        config: const ParticleConfig(particleCount: 50),
      );
      customSystem.devicePixelRatio = 1.0;
      await customSystem.init();

      const size = Size(400, 300);
      customSystem.screenSize = size;
      await customSystem.setText('Hi', size);
      expect(customSystem.particles.length, 50);
      customSystem.dispose();
    });

    test('tick notifies listeners', () async {
      await system.init();
      const size = Size(400, 300);
      system.screenSize = size;
      await system.setText('A', size);

      bool notified = false;
      system.addListener(() => notified = true);
      system.tick(pointer: system.pointer, config: system.config);
      expect(notified, isTrue);
    });
  });
}
