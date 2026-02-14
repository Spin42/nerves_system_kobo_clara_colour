# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.1.0] - 2025-12-27

### Added

- Initial Kobo Clara Colour Nerves system
- Support for Linux kernel with custom configuration
- fwup-based firmware updates with A/B partitioning
- Basic rootfs overlay with essential system files
- Buildroot-based system generation

### Features

- **Architecture**: arm
- **Toolchain**: armv7-nerves-linux-gnueabihf ~> 14.2
- **Firmware Updates**: A/B partition scheme with rollback
- **Build System**: Buildroot integration
- **Debug Support**: UART console and SSH access

[v0.1.0]: https://github.com/Spin42/nerves_system_kobo_clara_colour/releases/tag/v0.1.0
