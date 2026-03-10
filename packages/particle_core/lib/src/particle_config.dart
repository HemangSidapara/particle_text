import 'package:flutter/material.dart';

/// Configuration for particle widgets.
///
/// Controls particle behavior, appearance, physics, and text rendering.
///
/// ### How particle count works
///
/// Particle count is determined by [particleDensity], which defines how many
/// particles to spawn per 100,000 logical pixels² of **content area**
/// (the text bounding box or image drawn area — NOT the full screen).
///
/// This makes count automatically font-size-aware:
/// - Larger [fontSize] → bigger text bounding box → more content area → more particles
/// - Multi-line text → taller bounding box → more particles
/// - Larger images → more drawn area → more particles
///
/// Fine-tune coverage via [sampleGap] (lower = denser pixel sampling = more
/// target positions for particles to snap onto).
///
/// To override with an exact fixed count:
/// ```dart
/// ParticleConfig(particleCount: 6000)  // strict, ignores content size
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
  /// Fixed particle count. When set, this exact number is used regardless
  /// of text size, font size, or screen size.
  ///
  /// When null (default), particle count equals the number of sampled
  /// pixels from the text/image content, capped at [maxParticleCount].
  final int? particleCount;

  /// Particles per 100,000 logical pixels² of **content area**.
  ///
  /// Content area is the bounding box of the rendered text or the drawn
  /// area of the scaled image — NOT the full widget/screen size. This makes
  /// the count automatically scale with [fontSize]: a larger font produces a
  /// bigger bounding box, so more particles are spawned to fill it.
  ///
  /// The built-in ParticleText and ParticleImage widgets use this value
  /// via [effectiveParticleCount] to compute how many particles to create.
  ///
  /// Ignored when [particleCount] is set.
  final double particleDensity;

  /// Maximum particle count to prevent performance issues.
  /// Applies when count is auto-determined from content.
  /// Default: 50,000 (safe for drawRawAtlas rendering).
  final int maxParticleCount;

  /// Minimum particle count to ensure visibility on tiny screens.
  /// Only used with [effectiveParticleCount]. Default: 1,000.
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

  /// Sampling gap in pixels when rasterizing text/image.
  /// Lower = more sampled pixels = more particles = denser coverage.
  /// This is the primary control for particle density.
  ///
  /// ```dart
  /// ParticleConfig(sampleGap: 1)  // every pixel (densest)
  /// ParticleConfig(sampleGap: 2)  // every 2nd pixel (default)
  /// ParticleConfig(sampleGap: 4)  // every 4th pixel (sparser)
  /// ```
  final int sampleGap;

  /// Font weight used for rendering the text shape.
  final FontWeight fontWeight;

  /// Optional font family for the text shape.
  final String? fontFamily;

  /// Font size for text rendering in logical pixels.
  ///
  /// When null (default), a **responsive size** is computed automatically
  /// from the widget dimensions:
  /// ```
  /// min(widgetWidth, widgetHeight) × 0.18, clamped to [32, 200]
  /// ```
  /// This makes text look appropriately sized on all devices:
  /// - Mobile  (360px)  → ~48px
  /// - Tablet  (768px)  → ~90px
  /// - Desktop (1080px) → ~160px
  ///
  /// Set this explicitly to control text size. Text wraps when it
  /// exceeds widget width.
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
    this.particleDensity = 10000,
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

  /// Calculate particle count from [contentArea] and [particleDensity].
  ///
  /// [contentArea] is the area in logical pixels² of the actual content
  /// (text bounding box or image drawn area). The formula is:
  ///
  /// ```
  /// count = contentArea × particleDensity / 100,000
  /// ```
  ///
  /// So with the default density of 2000 and a text bounding box of
  /// 400×80 = 32,000 px², you get: 32000 × 2000 / 100000 = 640 particles.
  /// A bigger fontSize (e.g. 80 instead of 40) roughly doubles the
  /// bounding box area, doubling the particle count automatically.
  ///
  /// Returns [particleCount] directly when it is explicitly set.
  /// Result is clamped to [[minParticleCount], [maxParticleCount]].
  /// However, if [maxParticleCount] is the default (50,000) and the
  /// density-based count exceeds it, the density count is used instead.
  /// This lets users set high densities without being silently capped.
  int effectiveParticleCount(double contentArea) {
    if (particleCount != null) return particleCount!;

    // density = particles per 100,000 px² of content area
    final count = (contentArea * particleDensity / 100000).round();

    // Only enforce the hard cap if maxParticleCount was explicitly set
    // (i.e. not the default 50,000). Otherwise let density drive the count.
    final effectiveMax = (maxParticleCount == 50000 && count > maxParticleCount) ? count : maxParticleCount;

    final effectiveMin = minParticleCount <= effectiveMax ? minParticleCount : effectiveMax;
    return count.clamp(effectiveMin, effectiveMax);
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

  // Presets — all accept optional overrides for any parameter.

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
      particleDensity: particleDensity ?? 14000,
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
      particleDensity: particleDensity ?? 12000,
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
      particleDensity: particleDensity ?? 10000,
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
      particleDensity: particleDensity ?? 8500,
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
      particleDensity: particleDensity ?? 4500,
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
