/// A single particle in the system.
class Particle {
  /// Current position in logical pixels.
  double x, y;

  /// Target position the particle springs toward.
  double tx, ty;

  /// Current velocity.
  double vx, vy;

  /// Rendered radius in logical pixels.
  double size;

  /// Opacity (0.0–1.0).
  double alpha;

  /// Per-particle color as ARGB int. Used for image mode.
  /// When null, uses config-based color interpolation.
  int? targetColor;

  /// Creates a new particle with the given properties.
  Particle({
    required this.x,
    required this.y,
    required this.tx,
    required this.ty,
    this.vx = 0,
    this.vy = 0,
    required this.size,
    required this.alpha,
    this.targetColor,
  });
}
