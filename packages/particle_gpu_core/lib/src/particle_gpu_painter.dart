import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:particle_core/particle_core.dart';
import 'particle_gpu_compute_manager.dart';

/// Renders 100,000+ particles using super-fast drawRawAtlas.
class ParticleGPUPainter extends CustomPainter {
  final ParticleGPUComputeManager system;
  final ParticleConfig config;

  ParticleGPUPainter({
    required this.system,
    required this.config,
  }) : super(repaint: system);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // 1. Draw Background
    if (config.drawBackground) {
      canvas.drawRect(
        ui.Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = config.backgroundColor,
      );
    }

    // 2. Render ALL particles using drawRawAtlas (Performance Test)
    final sprite = system.sprite;
    final transforms = system.transforms;
    final rects = system.srcRects;
    final colors = system.atlasColors;

    if (sprite != null && transforms != null && rects != null && colors != null) {
      canvas.drawRawAtlas(
        sprite,
        transforms,
        rects,
        colors,
        BlendMode.modulate,
        null,
        Paint()..filterQuality = ui.FilterQuality.low,
      );
    }

    // 3. Status Indicator (Green Overlay)
    final readyPaint = Paint()..color = Colors.green.withValues(alpha: 0.8);
    canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 200, 30), readyPaint);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'GPU READY: ${system.particleCount}',
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, const ui.Offset(10, 5));
    
    // 4. Pointer Glow
    final pointer = system.pointer;
    if (config.showPointerGlow && pointer.dx > -1000) {
      final glowPaint = Paint()
        ..shader = ui.Gradient.radial(
          pointer,
          config.mouseRadius * 0.5,
          [
            config.pointerGlowColor.withValues(alpha: 0.3),
            config.pointerGlowColor.withValues(alpha: 0.0),
          ],
        );
      canvas.drawCircle(pointer, config.mouseRadius * 0.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticleGPUPainter oldDelegate) => true;
}
