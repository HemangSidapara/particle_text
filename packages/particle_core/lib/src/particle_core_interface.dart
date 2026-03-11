import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'particle_config.dart';

/// A shared interface for particle engines.
///
/// This allows high-level widgets like `ParticleText` to swap between
/// `particle_core` (Classic) and `particle_gpu_core` (High Performance).
abstract class IParticleCore extends ChangeNotifier {
  /// The current interaction point.
  ui.Offset get pointer;
  set pointer(ui.Offset value);

  /// The dimensions of the canvas.
  ui.Size get screenSize;
  set screenSize(ui.Size value);

  /// High-DPI scale factor.
  double get devicePixelRatio;
  set devicePixelRatio(double value);

  /// Run one physics step.
  void tick({
    required ui.Offset pointer,
    required ParticleConfig config,
  });

  Future<void> setText(String text, ui.Size size);
  Future<void> setImage(ui.Image image, ui.Size size);

  Float32List? get transforms;
  Float32List? get srcRects;
  Int32List? get atlasColors;

  ui.Image? get sprite;
}
