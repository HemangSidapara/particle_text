<p align="center">
  <img src="resources/banner_2800x800.png"
       alt="particle_text demo: Blue and cyan glowing particles form the word Flutter against a dark starry background. The particles scatter and reform responsively as the cursor moves across them, demonstrating spring physics interactions."
       width="900">
</p>

# particle_packages

A monorepo of Flutter packages for interactive particle effects.

## Packages

| Package                                    | Version                                                                                            | Description                           |
|--------------------------------------------|----------------------------------------------------------------------------------------------------|---------------------------------------|
| [particle_core](packages/particle_core/)   | [![pub](https://img.shields.io/pub/v/particle_core.svg)](https://pub.dev/packages/particle_core)   | Core physics engine and renderer      |
| [particle_text](packages/particle_text/)   | [![pub](https://img.shields.io/pub/v/particle_text.svg)](https://pub.dev/packages/particle_text)   | Text → interactive particles          |
| [particle_image](packages/particle_image/) | [![pub](https://img.shields.io/pub/v/particle_image.svg)](https://pub.dev/packages/particle_image) | Image → colored interactive particles |

## Architecture

```text
particle_core           ← engine, config, painter, physics
├── particle_text       ← ParticleText widget (depends on core)
└── particle_image      ← ParticleImage widget (depends on core)
```

Users install `particle_text` or `particle_image` (or both). They automatically get `particle_core`.

## Quick start

```yaml
# For text effects
dependencies:
  particle_text: ^0.2.0

# For image effects
dependencies:
  particle_image: ^0.2.0

# For both
dependencies:
  particle_text: ^0.2.0
  particle_image: ^0.2.0
```

## Development

This monorepo uses [Melos](https://melos.invertase.dev/) for managing packages.

```bash
# Install melos
dart pub global activate melos

# Bootstrap (links local packages)
melos bootstrap

# Run all tests
melos test

# Analyze all packages
melos analyze

# Dry-run publish
melos publish:dry

# Publish all packages
melos publish
```

## License

MIT License. See individual packages for details.
