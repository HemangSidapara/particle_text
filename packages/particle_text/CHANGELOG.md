## 0.2.0

* **Responsive resize**: particles automatically re-rasterize and reposition when widget size changes (window resize, orientation change)
* **Max particle count**: density-based count can exceed the default 50k cap; `maxParticleCount` only acts as a hard limit when explicitly set
* **Monorepo versioning**: all packages now share the same version number
* Requires `particle_core: ^0.2.0`

## 0.1.1

* Repository URL fix

## 0.1.0

* **BREAKING**: Core engine extracted to `particle_core` package
* ParticleText widget now depends on `particle_core` for physics and rendering
* Re-exports `particle_core` for convenience — no extra imports needed
* Removed `ParticleImage` (moved to separate `particle_image` package)

## 0.0.2

* Added responsive density-based particle count
* Single GPU draw call rendering via `drawRawAtlas`
* Fixed deprecated Flutter API warnings
* Fixed half-text rendering on high-DPR devices

## 0.0.1

* Initial release
