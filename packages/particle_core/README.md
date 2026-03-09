# particle_core

[![pub package](https://img.shields.io/pub/v/particle_core.svg)](https://pub.dev/packages/particle_core)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Core engine for particle effects in Flutter. High-performance physics, single GPU draw call
rendering, and full customization.

**You probably want [particle_text](https://pub.dev/packages/particle_text)
or [particle_image](https://pub.dev/packages/particle_image) instead** — they provide ready-to-use
widgets built on this engine.

## What's inside

- **ParticleSystem** — physics engine with spring forces, pointer repulsion, and text/image
  rasterization
- **ParticleConfig** — full configuration: colors, density, physics, fonts, presets
- **ParticlePainter** — high-performance renderer using `Canvas.drawRawAtlas` (single GPU draw call)
- **Particle** — data model for individual particles

## Use this package if

- You want to build a custom particle widget on top of the engine
- You need direct access to the physics system
- You're creating a new particle effect type beyond text and images

## Getting started

```yaml
dependencies:
  particle_core: ^0.0.1
```

## ParticleConfig options

| Parameter          | Type         | Default   | Description                                         |
|--------------------|--------------|-----------|-----------------------------------------------------|
| `particleDensity`  | `double`     | `2000`    | Particles per 100k px² of screen area (auto-scales) |
| `particleCount`    | `int?`       | `null`    | Fixed count — overrides density when set            |
| `maxParticleCount` | `int`        | `50000`   | Upper cap for density scaling                       |
| `minParticleCount` | `int`        | `1000`    | Lower floor for density scaling                     |
| `mouseRadius`      | `double`     | `80.0`    | Pointer repulsion radius (logical px)               |
| `returnSpeed`      | `double`     | `0.04`    | Spring return speed (0.01–0.1)                      |
| `friction`         | `double`     | `0.88`    | Velocity damping (0.8–0.95)                         |
| `repelForce`       | `double`     | `8.0`     | Pointer repulsion strength (1.0–20.0)               |
| `backgroundColor`  | `Color`      | `#020308` | Canvas background                                   |
| `particleColor`    | `Color`      | `#8CAADE` | Particle color at rest                              |
| `displacedColor`   | `Color`      | `#DCE5FF` | Particle color when scattered                       |
| `pointerGlowColor` | `Color`      | `#C8D2F0` | Glow orb color                                      |
| `minParticleSize`  | `double`     | `0.4`     | Min particle radius                                 |
| `maxParticleSize`  | `double`     | `2.2`     | Max particle radius                                 |
| `minAlpha`         | `double`     | `0.5`     | Min particle opacity                                |
| `maxAlpha`         | `double`     | `1.0`     | Max particle opacity                                |
| `sampleGap`        | `int`        | `2`       | Pixel sampling density (lower = more targets)       |
| `fontWeight`       | `FontWeight` | `bold`    | Text rendering weight                               |
| `fontFamily`       | `String?`    | `null`    | Custom font family                                  |
| `showPointerGlow`  | `bool`       | `true`    | Show pointer glow orb                               |
| `pointerDotRadius` | `double`     | `4.0`     | Center dot radius                                   |

### Built-in presets

| Preset                     | Density | Style                   |
|----------------------------|---------|-------------------------|
| `ParticleConfig()`         | 2000    | Default blue-white glow |
| `ParticleConfig.cosmic()`  | 2800    | Dense cosmic blue dust  |
| `ParticleConfig.fire()`    | 2400    | Fiery warm orange       |
| `ParticleConfig.matrix()`  | 2000    | Neon green              |
| `ParticleConfig.pastel()`  | 1700    | Soft pastel pink        |
| `ParticleConfig.minimal()` | 900     | Fewer, larger particles |

### Responsive particle count

Particle count scales automatically with screen size:

```
Mobile  (360×800)   → ~5,760 particles
Tablet  (768×1024)  → ~15,729 particles
Desktop (1920×1080) → ~41,472 particles
4K      (3840×2160) → ~50,000 particles (capped)
```

## Performance

`particle_core` renders all particles in a **single GPU draw call** using `Canvas.drawRawAtlas`.
This means 10,000+ particles run smoothly at 60fps — compared to traditional `drawCircle`
-per-particle approaches that start lagging at 1,000.

Other optimizations:

- **Pre-allocated `Float32List`/`Int32List` buffers** — zero GC pressure per frame
- **Squared-distance checks** — avoids `sqrt` in physics hot loops
- **`ChangeNotifier`-driven repainting** — no `setState`, no widget tree rebuilds
- **`RepaintBoundary` isolation** — only the canvas layer repaints
- **Pre-rendered sprite texture** — 32×32 soft glow circle created once, reused every frame

## License

MIT License. See [LICENSE](LICENSE) for details.
