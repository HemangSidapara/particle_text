import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:particle_core/particle_core.dart';

void main() {
  group('ParticleConfig', () {
    test('default values are set correctly', () {
      const config = ParticleConfig();

      expect(config.particleCount, isNull);
      expect(config.particleDensity, 10000);
      expect(config.maxParticleCount, 50000);
      expect(config.minParticleCount, 1000);
      expect(config.mouseRadius, 80.0);
      expect(config.returnSpeed, 0.04);
      expect(config.friction, 0.88);
      expect(config.repelForce, 8.0);
      expect(config.backgroundColor, const Color(0xFF020308));
      expect(config.minParticleSize, 0.4);
      expect(config.maxParticleSize, 2.2);
      expect(config.minAlpha, 0.5);
      expect(config.maxAlpha, 1.0);
      expect(config.sampleGap, 2);
      expect(config.fontWeight, FontWeight.bold);
      expect(config.fontFamily, isNull);
      expect(config.showPointerGlow, true);
      expect(config.pointerDotRadius, 4.0);
    });

    test('fixed particleCount overrides density', () {
      const config = ParticleConfig(particleCount: 5000);
      const mobileArea = 360.0 * 800.0; // 288,000 px²
      const desktopArea = 1920.0 * 1080.0; // 2,073,600 px²

      // Returns exact count regardless of content area
      expect(config.effectiveParticleCount(mobileArea), 5000);
      expect(config.effectiveParticleCount(desktopArea), 5000);
    });

    test('custom values override defaults', () {
      const config = ParticleConfig(
        particleCount: 3000,
        mouseRadius: 120.0,
        returnSpeed: 0.08,
        friction: 0.92,
        repelForce: 15.0,
        backgroundColor: Color(0xFF111111),
        particleColor: Color(0xFFFF0000),
        fontFamily: 'Roboto',
        showPointerGlow: false,
      );

      expect(config.particleCount, 3000);
      expect(config.mouseRadius, 120.0);
      expect(config.returnSpeed, 0.08);
      expect(config.friction, 0.92);
      expect(config.repelForce, 15.0);
      expect(config.backgroundColor, const Color(0xFF111111));
      expect(config.particleColor, const Color(0xFFFF0000));
      expect(config.fontFamily, 'Roboto');
      expect(config.showPointerGlow, false);
    });
  });

  group('ParticleConfig - responsive particle count', () {
    test('scales with content area (small text)', () {
      const config = ParticleConfig(); // density: 10000
      // e.g. text bounding box 400×80 at fontSize 40 = 32,000 px²
      const contentArea = 400.0 * 80.0; // 32,000 px²

      final count = config.effectiveParticleCount(contentArea);
      // 32000 * 10000 / 100000 = 3200
      expect(count, 3200);
    });

    test('scales with content area (large text)', () {
      const config = ParticleConfig();
      // e.g. text bounding box 800×160 at fontSize 80 = 128,000 px²
      const contentArea = 800.0 * 160.0; // 128,000 px²

      final count = config.effectiveParticleCount(contentArea);
      // 128000 * 10000 / 100000 = 12800
      expect(count, 12800);
    });

    test('scales with content area (multi-line text)', () {
      const config = ParticleConfig();
      // e.g. multi-line text block 600×400 = 240,000 px²
      const contentArea = 600.0 * 400.0; // 240,000 px²

      final count = config.effectiveParticleCount(contentArea);
      // 240000 * 10000 / 100000 = 24000
      expect(count, 24000);
    });

    test('respects maxParticleCount cap', () {
      const config = ParticleConfig(
        particleDensity: 5000,
        maxParticleCount: 20000,
      );
      // Very large content area
      const hugeArea = 3840.0 * 2160.0; // 8,294,400 px²

      final count = config.effectiveParticleCount(hugeArea);
      expect(count, 20000);
    });

    test('respects minParticleCount floor', () {
      const config = ParticleConfig(
        particleDensity: 100,
        minParticleCount: 2000,
      );
      // Very small content area
      const tinyArea = 200.0 * 300.0; // 60,000 px²

      final count = config.effectiveParticleCount(tinyArea);
      expect(count, 2000);
    });

    test('different densities produce proportional counts', () {
      const low = ParticleConfig(particleDensity: 1000);
      const high = ParticleConfig(particleDensity: 3000);
      const contentArea = 1000.0 * 1000.0; // 1,000,000 px²

      final lowCount = low.effectiveParticleCount(contentArea);
      final highCount = high.effectiveParticleCount(contentArea);

      // 1000000 * 1000 / 100000 = 10000
      // 1000000 * 3000 / 100000 = 30000
      expect(lowCount, 10000);
      expect(highCount, 30000);
      expect(highCount, 3 * lowCount);
    });
  });

  group('ParticleConfig - presets', () {
    test('cosmic preset has higher density', () {
      final config = ParticleConfig.cosmic();

      expect(config.particleDensity, 14000);
      expect(config.repelForce, 10.0);
      expect(config.friction, 0.86);
      expect(config.maxParticleSize, 1.8);
      expect(config.particleCount, isNull);
    });

    test('fire preset values', () {
      final config = ParticleConfig.fire();

      expect(config.particleDensity, 12000);
      expect(config.repelForce, 12.0);
      expect(config.returnSpeed, 0.03);
      expect(config.particleCount, isNull);
    });

    test('matrix preset values', () {
      final config = ParticleConfig.matrix();

      expect(config.particleDensity, 10000);
      expect(config.repelForce, 6.0);
      expect(config.friction, 0.90);
      expect(config.particleCount, isNull);
    });

    test('pastel preset values', () {
      final config = ParticleConfig.pastel();

      expect(config.particleDensity, 8500);
      expect(config.minParticleSize, 0.6);
      expect(config.maxParticleSize, 2.4);
      expect(config.particleCount, isNull);
    });

    test('minimal preset has lowest density', () {
      final config = ParticleConfig.minimal();

      expect(config.particleDensity, 4500);
      expect(config.minParticleSize, 1.0);
      expect(config.maxParticleSize, 3.0);
      expect(config.mouseRadius, 100);
      expect(config.sampleGap, 3);
      expect(config.particleCount, isNull);
    });

    test('all presets scale correctly with large content area', () {
      final presets = [
        ParticleConfig.cosmic(),
        ParticleConfig.fire(),
        ParticleConfig.matrix(),
        ParticleConfig.pastel(),
        ParticleConfig.minimal(),
      ];
      // Simulate a large multi-line text block (e.g. 800×600 = 480,000 px²)
      const largeContentArea = 800.0 * 600.0;

      for (final preset in presets) {
        final count = preset.effectiveParticleCount(largeContentArea);
        // With default maxParticleCount (50k), density can exceed it
        expect(count, greaterThan(preset.minParticleCount));
      }

      // When maxParticleCount is explicitly set, it acts as a hard cap
      const capped = ParticleConfig(maxParticleCount: 10000, particleDensity: 50000);
      expect(
        capped.effectiveParticleCount(largeContentArea),
        lessThanOrEqualTo(10000),
      );
    });
  });
}
