## 0.2.1

- **FEAT**(particle_core): implement responsive resizing, dark pixel visibility, and monorepo versioning (v0.2.0). ([8c666597](https://github.com/HemangSidapara/particle_packages/commit/8c666597c85e003f6e0f80616dad0810547fc2d4))
- **FEAT**(particle_core): implement content-aware density scaling and responsive font sizes. ([270aa397](https://github.com/HemangSidapara/particle_packages/commit/270aa397433387d1f2906eb85acc8131d65191ec))
- **FEAT**(particle_core): add support for custom font size, multi-line text, and transparent backgrounds. ([102d7ad8](https://github.com/HemangSidapara/particle_packages/commit/102d7ad83dcecf9324e20bde8f0fedafbd368cb5))
- **DOCS**: improve code documentation and add melos doc scripts. ([2baf45db](https://github.com/HemangSidapara/particle_packages/commit/2baf45db8274cded915f0896240adf63d96004a7))
- **DOCS**(readme): Update package dependency versions. ([c49b3ea2](https://github.com/HemangSidapara/particle_packages/commit/c49b3ea25d6f97c95e76300636e452efa6803871))

## 0.2.0

- **Dark pixel visibility**: image particles with near-black source colors now have brightness boosted (luminance < 80) while preserving hue and saturation
- **Max particle count**: density-based count can exceed the default 50k cap; `maxParticleCount` only acts as a hard limit when explicitly set
- **Monorepo versioning**: all packages now share the same version number

## 0.0.2

- Repository URL fix

## 0.0.1

- Initial release — extracted from particle_text
- ParticleSystem with spring physics and pointer repulsion
- ParticleConfig with responsive density + 5 presets
- ParticlePainter with single GPU draw call via drawRawAtlas
- Support for both text and image pixel sources
- Auto background color detection for images
