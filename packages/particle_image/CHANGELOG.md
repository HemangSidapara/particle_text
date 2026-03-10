## 0.2.0

* **Responsive resize**: particles automatically re-rasterize and reposition when widget size changes (window resize, orientation change)
* **Dark pixel visibility**: image content with dark/near-black pixels (e.g. logo text) is automatically brightened while preserving hue
* **Background options**: supports dark, light, and transparent backgrounds via `drawBackground` and `backgroundColor`
* **Max particle count**: density-based count can exceed the default 50k cap; `maxParticleCount` only acts as a hard limit when explicitly set
* **Monorepo versioning**: all packages now share the same version number
* Requires `particle_core: ^0.2.0`

## 0.0.2

* Repository URL fix

## 0.0.1

* Initial release
* ParticleImage widget — render images as colored particles
* ParticleImage.asset() for loading from Flutter assets
* Per-pixel color from source image
* Auto background color detection (solid backgrounds filtered)
* Powered by particle_core engine
