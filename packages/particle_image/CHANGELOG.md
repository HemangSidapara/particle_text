## 0.2.1

- **FEAT**(particle_core): implement responsive resizing, dark pixel visibility, and monorepo versioning (v0.2.0). ([8c666597](https://github.com/HemangSidapara/particle_packages/commit/8c666597c85e003f6e0f80616dad0810547fc2d4))
- **FEAT**(particle_core): implement content-aware density scaling and responsive font sizes. ([270aa397](https://github.com/HemangSidapara/particle_packages/commit/270aa397433387d1f2906eb85acc8131d65191ec))
- **FEAT**(particle_core): add support for custom font size, multi-line text, and transparent backgrounds. ([102d7ad8](https://github.com/HemangSidapara/particle_packages/commit/102d7ad83dcecf9324e20bde8f0fedafbd368cb5))
- **DOCS**: improve code documentation and add melos doc scripts. ([2baf45db](https://github.com/HemangSidapara/particle_packages/commit/2baf45db8274cded915f0896240adf63d96004a7))
- **DOCS**(readme): Update package dependency versions. ([c49b3ea2](https://github.com/HemangSidapara/particle_packages/commit/c49b3ea25d6f97c95e76300636e452efa6803871))

## 0.2.0

- **Responsive resize**: particles automatically re-rasterize and reposition when widget size changes (window resize, orientation change)
- **Dark pixel visibility**: image content with dark/near-black pixels (e.g. logo text) is automatically brightened while preserving hue
- **Background options**: supports dark, light, and transparent backgrounds via `drawBackground` and `backgroundColor`
- **Max particle count**: density-based count can exceed the default 50k cap; `maxParticleCount` only acts as a hard limit when explicitly set
- **Monorepo versioning**: all packages now share the same version number
- Requires `particle_core: ^0.2.0`

## 0.0.2

- Repository URL fix

## 0.0.1

- Initial release
- ParticleImage widget — render images as colored particles
- ParticleImage.asset() for loading from Flutter assets
- Per-pixel color from source image
- Auto background color detection (solid backgrounds filtered)
- Powered by particle_core engine
