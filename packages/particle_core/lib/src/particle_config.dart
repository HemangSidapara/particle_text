import 'package:flutter/material.dart';

/// Configuration for particle widgets.
///
/// Controls particle behavior, appearance, physics, and text rendering.
///
/// ### Responsive particle count
///
/// By default, particle count scales automatically with screen size
/// using [particleDensity]. This ensures text looks equally dense
/// on a mobile phone and a 4K desktop monitor.
///
/// ```dart
/// // Auto-scales (recommended)
/// ParticleConfig(particleDensity: 2000)
///
/// // Fixed count (manual override)
/// ParticleConfig(particleCount: 6000)
/// ```
///
/// ### Presets with overrides
///
/// ```dart
/// // Use preset as-is
/// ParticleConfig.cosmic()
///
/// // Override specific values
/// ParticleConfig.cosmic(fontSize: 48, drawBackground: false)
///
/// // Or use copyWith on any config
/// config.copyWith(particleColor: Colors.red, fontSize: 32)
/// ```
class ParticleConfig {
  /// Fixed particle count. When set, overrides [particleDensity].
  /// Use this only when you need an exact number regardless of screen size.
  final int? particleCount;

  /// Particles per 100,000 logical pixels² of screen area.
  /// The effective count is calculated as:
  ///
  /// `effectiveCount = (screenWidth × screenHeight × density / 100000)`
  ///
  /// Reference values at default density (2000):
  /// - Mobile  (360×800)  → ~5,760 particles
  /// - Tablet  (768×1024) → ~15,729 particles
  /// - Desktop (1920×1080) → ~41,472 particles
  ///
  /// Ignored when [particleCount] is set.
  final double particleDensity;

  /// Maximum particle count to prevent performance issues on very
  /// large screens. Only applies when using [particleDensity].
  /// Default: 50,000 (safe for drawRawAtlas rendering).
  final int maxParticleCount;

  /// Minimum particle count to ensure text is visible on tiny screens.
  /// Only applies when using [particleDensity]. Default: 1,000.
  final int minParticleCount;

  /// Radius around the pointer that repels particles (in logical pixels).
  final double mouseRadius;

  /// How fast particles spring back to their target position.
  /// Range: 0.01 (very slow) to 0.1 (snappy). Default: 0.04.
  final double returnSpeed;

  /// Velocity damping per frame. Lower = more drag.
  /// Range: 0.8 (heavy drag) to 0.95 (floaty). Default: 0.88.
  final double friction;

  /// Strength of the repulsion force from the pointer.
  /// Range: 1.0 (gentle) to 20.0 (explosive). Default: 8.0.
  final double repelForce;

  /// Background color of the canvas.
  final Color backgroundColor;

  /// Base color of particles when at rest (near their target).
  final Color particleColor;

  /// Highlight color of particles when displaced far from target.
  final Color displacedColor;

  /// Color of the pointer glow orb.
  final Color pointerGlowColor;

  /// Minimum particle radius.
  final double minParticleSize;

  /// Maximum particle radius.
  final double maxParticleSize;

  /// Minimum particle opacity (0.0–1.0).
  final double minAlpha;

  /// Maximum particle opacity (0.0–1.0).
  final double maxAlpha;

  /// Sampling gap in physical pixels when rasterizing text.
  /// Lower = more text-pixel targets (denser coverage). Default: 2.
  final int sampleGap;

  /// Font weight used for rendering the text shape.
  final FontWeight fontWeight;

  /// Optional font family for the text shape.
  final String? fontFamily;

  /// Font size for text rendering in logical pixels.
  /// When null, defaults to 60.0. Set this to control text size
  /// and enable multi-line wrapping (text wraps when it exceeds widget width).
  final double? fontSize;

  /// Text alignment for multi-line text.
  final TextAlign textAlign;

  /// Whether to draw the [backgroundColor] as a solid rect behind particles.
  /// Set to false for transparent/overlay usage on any background.
  final bool drawBackground;

  /// Whether to show the pointer glow orb.
  final bool showPointerGlow;

  /// Radius of the bright dot at the pointer center.
  final double pointerDotRadius;

  const ParticleConfig({
    this.particleCount,
    this.particleDensity = 2000,
    this.maxParticleCount = 50000,
    this.minParticleCount = 1000,
    this.mouseRadius = 80.0,
    this.returnSpeed = 0.04,
    this.friction = 0.88,
    this.repelForce = 8.0,
    this.backgroundColor = const Color(0xFF020308),
    this.particleColor = const Color(0xFF8CAADE),
    this.displacedColor = const Color(0xFFDCE5FF),
    this.pointerGlowColor = const Color(0xFFC8D2F0),
    this.minParticleSize = 0.4,
    this.maxParticleSize = 2.2,
    this.minAlpha = 0.5,
    this.maxAlpha = 1.0,
    this.sampleGap = 2,
    this.fontWeight = FontWeight.bold,
    this.fontFamily,
    this.fontSize,
    this.textAlign = TextAlign.center,
    this.drawBackground = true,
    this.showPointerGlow = true,
    this.pointerDotRadius = 4.0,
  });

  /// Calculate effective particle count for the given screen [size].
  ///
  /// If [particleCount] is set, returns that value directly.
  /// Otherwise, scales based on [particleDensity] and screen area.
  int effectiveParticleCount(Size size) {
    if (particleCount != null) return particleCount!;

    final area = size.width * size.height;
    final count = (area * particleDensity / 100000).round();
    return count.clamp(minParticleCount, maxParticleCount);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ParticleConfig) return false;
    return particleCount == other.particleCount &&
        particleDensity == other.particleDensity &&
        maxParticleCount == other.maxParticleCount &&
        minParticleCount == other.minParticleCount &&
        mouseRadius == other.mouseRadius &&
        returnSpeed == other.returnSpeed &&
        friction == other.friction &&
        repelForce == other.repelForce &&
        backgroundColor == other.backgroundColor &&
        particleColor == other.particleColor &&
        displacedColor == other.displacedColor &&
        pointerGlowColor == other.pointerGlowColor &&
        minParticleSize == other.minParticleSize &&
        maxParticleSize == other.maxParticleSize &&
        minAlpha == other.minAlpha &&
        maxAlpha == other.maxAlpha &&
        sampleGap == other.sampleGap &&
        fontWeight == other.fontWeight &&
        fontFamily == other.fontFamily &&
        fontSize == other.fontSize &&
        textAlign == other.textAlign &&
        drawBackground == other.drawBackground &&
        showPointerGlow == other.showPointerGlow &&
        pointerDotRadius == other.pointerDotRadius;
  }

  @override
  int get hashCode {
    return Object.hash(
      particleCount,
      particleDensity,
      maxParticleCount,
      minParticleCount,
      mouseRadius,
      returnSpeed,
      friction,
      repelForce,
      backgroundColor,
      particleColor,
      displacedColor,
      pointerGlowColor,
      minParticleSize,
      maxParticleSize,
      minAlpha,
      maxAlpha,
      Object.hash(
        sampleGap,
        fontWeight,
        fontFamily,
        fontSize,
        textAlign,
        drawBackground,
        showPointerGlow,
        pointerDotRadius,
      ),
    );
  }

  /// Creates a copy of this config with the given fields replaced.
  ParticleConfig copyWith({
    int? particleCount,
    double? particleDensity,
    int? maxParticleCount,
    int? minParticleCount,
    double? mouseRadius,
    double? returnSpeed,
    double? friction,
    double? repelForce,
    Color? backgroundColor,
    Color? particleColor,
    Color? displacedColor,
    Color? pointerGlowColor,
    double? minParticleSize,
    double? maxParticleSize,
    double? minAlpha,
    double? maxAlpha,
    int? sampleGap,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    TextAlign? textAlign,
    bool? drawBackground,
    bool? showPointerGlow,
    double? pointerDotRadius,
  }) {
    return ParticleConfig(
      particleCount: particleCount ?? this.particleCount,
      particleDensity: particleDensity ?? this.particleDensity,
      maxParticleCount: maxParticleCount ?? this.maxParticleCount,
      minParticleCount: minParticleCount ?? this.minParticleCount,
      mouseRadius: mouseRadius ?? this.mouseRadius,
      returnSpeed: returnSpeed ?? this.returnSpeed,
      friction: friction ?? this.friction,
      repelForce: repelForce ?? this.repelForce,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      particleColor: particleColor ?? this.particleColor,
      displacedColor: displacedColor ?? this.displacedColor,
      pointerGlowColor: pointerGlowColor ?? this.pointerGlowColor,
      minParticleSize: minParticleSize ?? this.minParticleSize,
      maxParticleSize: maxParticleSize ?? this.maxParticleSize,
      minAlpha: minAlpha ?? this.minAlpha,
      maxAlpha: maxAlpha ?? this.maxAlpha,
      sampleGap: sampleGap ?? this.sampleGap,
      fontWeight: fontWeight ?? this.fontWeight,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textAlign: textAlign ?? this.textAlign,
      drawBackground: drawBackground ?? this.drawBackground,
      showPointerGlow: showPointerGlow ?? this.showPointerGlow,
      pointerDotRadius: pointerDotRadius ?? this.pointerDotRadius,
    );
  }

  // ── Presets ─────────────────────────────────────────────────────
  // All presets accept optional overrides for any parameter.

  /// Preset: dense cosmic dust look.
  ///
  /// ```dart
  /// ParticleConfig.cosmic()
  /// ParticleConfig.cosmic(fontSize: 48, drawBackground: false)
  /// ```
  factory ParticleConfig.cosmic({
    int? particleCount,
    double? particleDensity,
    int? maxParticleCount,
    int? minParticleCount,
    double? mouseRadius,
    double? returnSpeed,
    double? friction,
    double? repelForce,
    Color? backgroundColor,
    Color? particleColor,
    Color? displacedColor,
    Color? pointerGlowColor,
    double? minParticleSize,
    double? maxParticleSize,
    double? minAlpha,
    double? maxAlpha,
    int? sampleGap,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    TextAlign? textAlign,
    bool? drawBackground,
    bool? showPointerGlow,
    double? pointerDotRadius,
  }) {
    return ParticleConfig(
      particleCount: particleCount,
      particleDensity: particleDensity ?? 2800,
      maxParticleCount: maxParticleCount ?? 50000,
      minParticleCount: minParticleCount ?? 1000,
      mouseRadius: mouseRadius ?? 80.0,
      returnSpeed: returnSpeed ?? 0.04,
      friction: friction ?? 0.86,
      repelForce: repelForce ?? 10.0,
      backgroundColor: backgroundColor ?? const Color(0xFF05060F),
      particleColor: particleColor ?? const Color(0xFF6E7FCC),
      displacedColor: displacedColor ?? const Color(0xFFA8C4FF),
      pointerGlowColor: pointerGlowColor ?? const Color(0xFF8090E0),
      minParticleSize: minParticleSize ?? 0.4,
      maxParticleSize: maxParticleSize ?? 1.8,
      minAlpha: minAlpha ?? 0.5,
      maxAlpha: maxAlpha ?? 1.0,
      sampleGap: sampleGap ?? 2,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontFamily: fontFamily,
      fontSize: fontSize,
      textAlign: textAlign ?? TextAlign.center,
      drawBackground: drawBackground ?? true,
      showPointerGlow: showPointerGlow ?? true,
      pointerDotRadius: pointerDotRadius ?? 4.0,
    );
  }

  /// Preset: fiery warm particles.
  ///
  /// ```dart
  /// ParticleConfig.fire()
  /// ParticleConfig.fire(fontSize: 72, repelForce: 15.0)
  /// ```
  factory ParticleConfig.fire({
    int? particleCount,
    double? particleDensity,
    int? maxParticleCount,
    int? minParticleCount,
    double? mouseRadius,
    double? returnSpeed,
    double? friction,
    double? repelForce,
    Color? backgroundColor,
    Color? particleColor,
    Color? displacedColor,
    Color? pointerGlowColor,
    double? minParticleSize,
    double? maxParticleSize,
    double? minAlpha,
    double? maxAlpha,
    int? sampleGap,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    TextAlign? textAlign,
    bool? drawBackground,
    bool? showPointerGlow,
    double? pointerDotRadius,
  }) {
    return ParticleConfig(
      particleCount: particleCount,
      particleDensity: particleDensity ?? 2400,
      maxParticleCount: maxParticleCount ?? 50000,
      minParticleCount: minParticleCount ?? 1000,
      mouseRadius: mouseRadius ?? 80.0,
      returnSpeed: returnSpeed ?? 0.03,
      friction: friction ?? 0.88,
      repelForce: repelForce ?? 12.0,
      backgroundColor: backgroundColor ?? const Color(0xFF0A0504),
      particleColor: particleColor ?? const Color(0xFFCC6633),
      displacedColor: displacedColor ?? const Color(0xFFFFCC44),
      pointerGlowColor: pointerGlowColor ?? const Color(0xFFFF8844),
      minParticleSize: minParticleSize ?? 0.4,
      maxParticleSize: maxParticleSize ?? 2.0,
      minAlpha: minAlpha ?? 0.5,
      maxAlpha: maxAlpha ?? 1.0,
      sampleGap: sampleGap ?? 2,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontFamily: fontFamily,
      fontSize: fontSize,
      textAlign: textAlign ?? TextAlign.center,
      drawBackground: drawBackground ?? true,
      showPointerGlow: showPointerGlow ?? true,
      pointerDotRadius: pointerDotRadius ?? 4.0,
    );
  }

  /// Preset: neon green matrix style.
  ///
  /// ```dart
  /// ParticleConfig.matrix()
  /// ParticleConfig.matrix(fontSize: 40, fontFamily: 'Courier')
  /// ```
  factory ParticleConfig.matrix({
    int? particleCount,
    double? particleDensity,
    int? maxParticleCount,
    int? minParticleCount,
    double? mouseRadius,
    double? returnSpeed,
    double? friction,
    double? repelForce,
    Color? backgroundColor,
    Color? particleColor,
    Color? displacedColor,
    Color? pointerGlowColor,
    double? minParticleSize,
    double? maxParticleSize,
    double? minAlpha,
    double? maxAlpha,
    int? sampleGap,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    TextAlign? textAlign,
    bool? drawBackground,
    bool? showPointerGlow,
    double? pointerDotRadius,
  }) {
    return ParticleConfig(
      particleCount: particleCount,
      particleDensity: particleDensity ?? 2000,
      maxParticleCount: maxParticleCount ?? 50000,
      minParticleCount: minParticleCount ?? 1000,
      mouseRadius: mouseRadius ?? 80.0,
      returnSpeed: returnSpeed ?? 0.04,
      friction: friction ?? 0.90,
      repelForce: repelForce ?? 6.0,
      backgroundColor: backgroundColor ?? const Color(0xFF010A02),
      particleColor: particleColor ?? const Color(0xFF00CC44),
      displacedColor: displacedColor ?? const Color(0xFF88FF88),
      pointerGlowColor: pointerGlowColor ?? const Color(0xFF44FF66),
      minParticleSize: minParticleSize ?? 0.4,
      maxParticleSize: maxParticleSize ?? 1.6,
      minAlpha: minAlpha ?? 0.5,
      maxAlpha: maxAlpha ?? 1.0,
      sampleGap: sampleGap ?? 2,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontFamily: fontFamily,
      fontSize: fontSize,
      textAlign: textAlign ?? TextAlign.center,
      drawBackground: drawBackground ?? true,
      showPointerGlow: showPointerGlow ?? true,
      pointerDotRadius: pointerDotRadius ?? 4.0,
    );
  }

  /// Preset: soft pastel glow.
  ///
  /// ```dart
  /// ParticleConfig.pastel()
  /// ParticleConfig.pastel(drawBackground: false, fontSize: 36)
  /// ```
  factory ParticleConfig.pastel({
    int? particleCount,
    double? particleDensity,
    int? maxParticleCount,
    int? minParticleCount,
    double? mouseRadius,
    double? returnSpeed,
    double? friction,
    double? repelForce,
    Color? backgroundColor,
    Color? particleColor,
    Color? displacedColor,
    Color? pointerGlowColor,
    double? minParticleSize,
    double? maxParticleSize,
    double? minAlpha,
    double? maxAlpha,
    int? sampleGap,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    TextAlign? textAlign,
    bool? drawBackground,
    bool? showPointerGlow,
    double? pointerDotRadius,
  }) {
    return ParticleConfig(
      particleCount: particleCount,
      particleDensity: particleDensity ?? 1700,
      maxParticleCount: maxParticleCount ?? 50000,
      minParticleCount: minParticleCount ?? 1000,
      mouseRadius: mouseRadius ?? 80.0,
      returnSpeed: returnSpeed ?? 0.03,
      friction: friction ?? 0.90,
      repelForce: repelForce ?? 6.0,
      backgroundColor: backgroundColor ?? const Color(0xFF0A0610),
      particleColor: particleColor ?? const Color(0xFFDDA0DD),
      displacedColor: displacedColor ?? const Color(0xFFFFE4F0),
      pointerGlowColor: pointerGlowColor ?? const Color(0xFFFFB6D9),
      minParticleSize: minParticleSize ?? 0.6,
      maxParticleSize: maxParticleSize ?? 2.4,
      minAlpha: minAlpha ?? 0.5,
      maxAlpha: maxAlpha ?? 1.0,
      sampleGap: sampleGap ?? 2,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontFamily: fontFamily,
      fontSize: fontSize,
      textAlign: textAlign ?? TextAlign.center,
      drawBackground: drawBackground ?? true,
      showPointerGlow: showPointerGlow ?? true,
      pointerDotRadius: pointerDotRadius ?? 4.0,
    );
  }

  /// Preset: minimal with fewer, larger particles.
  ///
  /// ```dart
  /// ParticleConfig.minimal()
  /// ParticleConfig.minimal(particleColor: Colors.black, drawBackground: false)
  /// ```
  factory ParticleConfig.minimal({
    int? particleCount,
    double? particleDensity,
    int? maxParticleCount,
    int? minParticleCount,
    double? mouseRadius,
    double? returnSpeed,
    double? friction,
    double? repelForce,
    Color? backgroundColor,
    Color? particleColor,
    Color? displacedColor,
    Color? pointerGlowColor,
    double? minParticleSize,
    double? maxParticleSize,
    double? minAlpha,
    double? maxAlpha,
    int? sampleGap,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    TextAlign? textAlign,
    bool? drawBackground,
    bool? showPointerGlow,
    double? pointerDotRadius,
  }) {
    return ParticleConfig(
      particleCount: particleCount,
      particleDensity: particleDensity ?? 900,
      maxParticleCount: maxParticleCount ?? 50000,
      minParticleCount: minParticleCount ?? 1000,
      mouseRadius: mouseRadius ?? 100.0,
      returnSpeed: returnSpeed ?? 0.04,
      friction: friction ?? 0.88,
      repelForce: repelForce ?? 10.0,
      backgroundColor: backgroundColor ?? const Color(0xFF111111),
      particleColor: particleColor ?? const Color(0xFFCCCCCC),
      displacedColor: displacedColor ?? const Color(0xFFFFFFFF),
      pointerGlowColor: pointerGlowColor ?? const Color(0xFFEEEEEE),
      minParticleSize: minParticleSize ?? 1.0,
      maxParticleSize: maxParticleSize ?? 3.0,
      minAlpha: minAlpha ?? 0.5,
      maxAlpha: maxAlpha ?? 1.0,
      sampleGap: sampleGap ?? 3,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontFamily: fontFamily,
      fontSize: fontSize,
      textAlign: textAlign ?? TextAlign.center,
      drawBackground: drawBackground ?? true,
      showPointerGlow: showPointerGlow ?? true,
      pointerDotRadius: pointerDotRadius ?? 4.0,
    );
  }
}
