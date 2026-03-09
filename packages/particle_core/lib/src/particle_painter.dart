import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'particle_system.dart';
import 'particle_config.dart';

/// High-performance particle renderer.
///
/// Renders ALL particles in a **single GPU draw call** using
/// [Canvas.drawRawAtlas] with a pre-rendered sprite texture.
///
/// Supports transparent, light, and dark backgrounds via
/// [ParticleConfig.drawBackground].
class ParticlePainter extends CustomPainter {
  final ParticleSystem system;
  final ParticleConfig config;

  // Cached paints
  final Paint _bgPaint;
  final Paint _atlasPaint;
  final Paint _dotPaint = Paint();

  ParticlePainter({
    required this.system,
    required this.config,
  })  : _bgPaint = Paint()..color = config.backgroundColor,
        _atlasPaint = Paint(), // default srcOver — works on any background
        super(repaint: system);

  @override
  void paint(Canvas canvas, Size size) {
    // Background (optional — set drawBackground: false for transparent)
    if (config.drawBackground) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        _bgPaint,
      );
    }

    // Draw ALL particles in one call
    final sprite = system.sprite;
    final transforms = system.transforms;
    final rects = system.srcRects;
    final colors = system.atlasColors;

    if (sprite != null &&
        transforms != null &&
        rects != null &&
        colors != null &&
        transforms.isNotEmpty) {
      canvas.drawRawAtlas(
        sprite,
        transforms,
        rects,
        colors,
        BlendMode.modulate, // tint white sprite with per-particle color
        null,
        _atlasPaint,
      );
    }

    // Pointer glow
    final pointer = system.pointer;
    if (config.showPointerGlow && pointer.dx > -1000) {
      _drawPointerGlow(canvas, pointer);
    }
  }

  void _drawPointerGlow(Canvas canvas, Offset pointer) {
    final glowRadius = config.mouseRadius * 0.6;
    final glowColor = config.pointerGlowColor;

    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        pointer,
        glowRadius,
        [
          glowColor.withValues(alpha: 0.35),
          glowColor.withValues(alpha: 0.10),
          glowColor.withValues(alpha: 0.0),
        ],
        [0.0, 0.4, 1.0],
      );
    canvas.drawCircle(pointer, glowRadius, glowPaint);

    _dotPaint.color = glowColor.withValues(alpha: 0.8);
    canvas.drawCircle(pointer, config.pointerDotRadius, _dotPaint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => false;
}
