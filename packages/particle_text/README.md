# particle_text

[![pub package](https://img.shields.io/pub/v/particle_text.svg)](https://pub.dev/packages/particle_text)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Interactive particle text effect for Flutter. Thousands of particles form text shapes and scatter on
touch/hover, then spring back — with full customization.

> Looking for image-to-particle? See [particle_image](https://pub.dev/packages/particle_image).

## 🔴 Live Demo

**[Try it in your browser →](https://hemangsidapara.github.io/particle_packages/)**

Move your cursor or touch to scatter the particles!

## Preview

<!--suppress HtmlDeprecatedAttribute -->
<p align="center">
  <img src="https://raw.githubusercontent.com/HemangSidapara/particle_packages/master/preview/text_preview.gif" alt="particle_text demo" width="600"/>
</p>

## Features

- **Touch & hover interaction** — particles scatter away from your finger/cursor
- **Spring physics** — smooth, natural particle reformation
- **Fully customizable** — colors, particle count, physics, font, and more
- **Built-in presets** — cosmic, fire, matrix, pastel, minimal
- **Powered by particle_core** — high-performance single GPU draw call engine
- **Cross-platform** — works on iOS, Android, Web, macOS, Windows, Linux

## Getting started

```yaml
dependencies:
  particle_text: ^0.2.0
```

## Usage

### Basic

```dart
import 'package:particle_text/particle_text.dart';

ParticleText(text: 'Hello')
```

### With configuration

```dart
ParticleText(
  text: 'Flutter',
  config: ParticleConfig(
    fontSize: 80,
    particleColor: Color(0xFF8CAADE),
    displacedColor: Color(0xFFDCE5FF),
    backgroundColor: Color(0xFF020308),
    mouseRadius: 80,
    repelForce: 8.0,
    returnSpeed: 0.04,
  ),
)
```

### Using presets

```dart
// Cosmic blue dust
ParticleText(text: 'Cosmic', config: ParticleConfig.cosmic())

// Fiery warm particles
ParticleText(text: 'Fire', config: ParticleConfig.fire())

// Neon green matrix
ParticleText(text: 'Matrix', config: ParticleConfig.matrix())

// Soft pastel glow
ParticleText(text: 'Pastel', config: ParticleConfig.pastel())

// Fewer, larger particles
ParticleText(text: 'Clean', config: ParticleConfig.minimal())
```

### Dynamic text

Simply update the `text` parameter and the particles will morph:

```dart
ParticleText(
  text: _currentText, // change this and particles re-target
  onTextChanged: () => print('Morphing!'),
)
```

### Fixed size (non-expanding)

By default, `ParticleText` expands to fill its parent. To use a fixed size:

```dart
SizedBox(
  width: 400,
  height: 300,
  child: ParticleText(
    text: 'Sized',
    expand: false,
  ),
)
```

### Inside Expanded

Use `ParticleText` alongside other widgets in a `Column` or `Row`:

```dart
Column(
  children: [
    AppBar(title: Text('My App')),
    Expanded(
      child: ParticleText(text: 'Hello'),
    ),
    BottomNavigationBar(...),
  ],
)
```

## ParticleConfig options

| Parameter          | Type         | Default   | Description                                                           |
|--------------------|--------------|-----------|-----------------------------------------------------------------------|
| `particleCount`    | `int?`       | `null`    | Fixed count — strict override, ignores content size                   |
| `particleDensity`  | `double`     | `10000`   | Particles per 100K px² of text bounding-box area                      |
| `maxParticleCount` | `int`        | `50000`   | Hard cap when explicitly set; density can exceed default 50k          |
| `minParticleCount` | `int`        | `1000`    | Lower floor for density-based count                                   |
| `mouseRadius`      | `double`     | `80.0`    | Pointer repulsion radius (logical px)                                 |
| `returnSpeed`      | `double`     | `0.04`    | Spring return speed (0.01–0.1)                                        |
| `friction`         | `double`     | `0.88`    | Velocity damping (0.8–0.95)                                           |
| `repelForce`       | `double`     | `8.0`     | Pointer repulsion strength (1.0–20.0)                                 |
| `backgroundColor`  | `Color`      | `#020308` | Canvas background                                                     |
| `particleColor`    | `Color`      | `#8CAADE` | Particle color at rest                                                |
| `displacedColor`   | `Color`      | `#DCE5FF` | Particle color when scattered                                         |
| `pointerGlowColor` | `Color`      | `#C8D2F0` | Glow orb color                                                        |
| `minParticleSize`  | `double`     | `0.4`     | Min particle radius                                                   |
| `maxParticleSize`  | `double`     | `2.2`     | Max particle radius                                                   |
| `minAlpha`         | `double`     | `0.5`     | Min particle opacity                                                  |
| `maxAlpha`         | `double`     | `1.0`     | Max particle opacity                                                  |
| `sampleGap`        | `int`        | `2`       | Pixel sampling gap (lower = more target positions)                    |
| `fontWeight`       | `FontWeight` | `bold`    | Text rendering weight                                                 |
| `fontFamily`       | `String?`    | `null`    | Custom font family                                                    |
| `fontSize`         | `double?`    | `null`    | Font size — responsive when null (scales with widget size, 32–200 px) |
| `textAlign`        | `TextAlign`  | `center`  | Text alignment for multi-line text                                    |
| `drawBackground`   | `bool`       | `true`    | Draw solid background or transparent/overlay                          |
| `showPointerGlow`  | `bool`       | `true`    | Show pointer glow orb                                                 |
| `pointerDotRadius` | `double`     | `4.0`     | Center dot radius                                                     |

### How particle count works

Particle count is determined by `particleDensity` × **text bounding-box area**:

```
count = textWidth × textHeight × particleDensity / 100,000
```

- Larger `fontSize` → bigger bounding box → more particles automatically
- Multi-line text → taller bounding box → more particles
- `sampleGap` controls pixel target density (lower = denser target positions)
- `fontSize` is **responsive** when null — auto-scales with widget size (32–200 px)

To force an exact count (ignores content size):

```dart
ParticleConfig(particleCount: 6000)  // always exactly 6000
```

> **Max count behavior:** When `maxParticleCount` is left at its default (50,000), density-based counts can exceed it. Set a custom value to enforce a hard cap.

### Responsive resize

`ParticleText` automatically re-rasterizes and repositions particles when the widget size changes (e.g. window resize, orientation change, layout changes). No extra code needed.

## Performance

`particle_text` renders all particles in a **single GPU draw call** using `Canvas.drawRawAtlas` (
powered by `particle_core`). This means 10,000+ particles run smoothly at 60fps.

Key optimizations: pre-allocated typed array buffers (zero GC), squared-distance physics (avoids
`sqrt`), `ChangeNotifier`-driven repainting (no `setState` / no widget rebuilds), and
`RepaintBoundary` isolation.

## Related packages

| Package                                                   | Description                   |
|-----------------------------------------------------------|-------------------------------|
| [particle_core](https://pub.dev/packages/particle_core)   | Core engine (used internally) |
| [particle_image](https://pub.dev/packages/particle_image) | Image-to-particle effect      |

## License

MIT License. See [LICENSE](LICENSE) for details.
