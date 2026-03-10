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
  particle_core: ^0.2.0
```

## ParticleConfig options

| Parameter          | Type         | Default   | Description                                                           |
|--------------------|--------------|-----------|-----------------------------------------------------------------------|
| `particleCount`    | `int?`       | `null`    | Fixed count — strict override, ignores content size                   |
| `particleDensity`  | `double`     | `10000`   | Particles per 100K px² of content area (text bbox / image drawn area) |
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
| `sampleGap`        | `int`        | `2`       | Pixel sampling gap (lower = more target positions for particles)      |
| `fontWeight`       | `FontWeight` | `bold`    | Text rendering weight                                                 |
| `fontFamily`       | `String?`    | `null`    | Custom font family                                                    |
| `fontSize`         | `double?`    | `null`    | Font size — responsive when null (scales with widget size, 32–200 px) |
| `textAlign`        | `TextAlign`  | `center`  | Text alignment for multi-line text                                    |
| `drawBackground`   | `bool`       | `true`    | Draw solid background or transparent/overlay                          |
| `showPointerGlow`  | `bool`       | `true`    | Show pointer glow orb                                                 |
| `pointerDotRadius` | `double`     | `4.0`     | Center dot radius                                                     |

### Built-in presets

| Preset                     | Density | Style                   |
|----------------------------|---------|-------------------------|
| `ParticleConfig()`         | 10000   | Default blue-white glow |
| `ParticleConfig.cosmic()`  | 14000   | Dense cosmic blue dust  |
| `ParticleConfig.fire()`    | 12000   | Fiery warm orange       |
| `ParticleConfig.matrix()`  | 10000   | Neon green              |
| `ParticleConfig.pastel()`  | 8500    | Soft pastel pink        |
| `ParticleConfig.minimal()` | 4500    | Fewer, larger particles |

### How particle count works

Particle count is determined by `particleDensity` × **content area**:

```text
count = contentArea × particleDensity / 100,000
```

- **Content area** = text bounding box (width × height) or image drawn area — NOT the full screen
- Larger `fontSize` → bigger bounding box → more particles automatically
- Multi-line text → taller bounding box → more particles
- `sampleGap` controls how many target positions are sampled (lower = denser pixel targets)
- `fontSize` is **responsive** when null — auto-scales with widget size (32–200 px)

To force an exact count: `ParticleConfig(particleCount: 6000)`

> **Max count behavior:** When `maxParticleCount` is left at its default (50,000), the density-based count is allowed to exceed it. The cap only applies when you explicitly set a custom `maxParticleCount`.

### Responsive resize

Both `ParticleText` and `ParticleImage` detect widget size changes (e.g. window resize, orientation change) and automatically re-rasterize content and reposition particles at the new size.

### Dark image pixel visibility

Image particles with very dark/near-black source colors (luminance < 80) have their brightness automatically boosted while preserving hue and saturation. This ensures logos and text within images remain visible as particles regardless of background color.

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