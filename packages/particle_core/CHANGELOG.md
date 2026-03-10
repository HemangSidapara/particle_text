## 0.2.0

* **Dark pixel visibility**: image particles with near-black source colors now have brightness boosted (luminance < 80) while preserving hue and saturation
* **Max particle count**: density-based count can exceed the default 50k cap; `maxParticleCount` only acts as a hard limit when explicitly set
* **Monorepo versioning**: all packages now share the same version number

## 0.0.2

* Repository URL fix

## 0.0.1

* Initial release — extracted from particle_text
* ParticleSystem with spring physics and pointer repulsion
* ParticleConfig with responsive density + 5 presets
* ParticlePainter with single GPU draw call via drawRawAtlas
* Support for both text and image pixel sources
* Auto background color detection for images
