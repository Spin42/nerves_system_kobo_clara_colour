# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.2.0] - 2026-07-13

### Changed

- Toolchain: Kobo Linaro GCC 4.9.4 / glibc 2.19 replaced by the Spin42
  crosstool-NG toolchain (GCC 11.5.0, glibc 2.40, Linux 4.9 kernel headers).
  Modern userspace (C++17, Rust NIFs) can now target the device; stock Kobo
  blobs keep working via glibc backwards compatibility.
- nerves_system_br 1.33 -> 1.34: Buildroot 2026.05, Erlang/OTP 29.0.2
- Kernel 4.9.77 now builds with GCC 11 / binutils 2.4x (section-flag and
  jiffies declaration patches, plus suppression of warnings promoted since
  GCC 8 that the vendor tree turns into errors)
- libnl 3.12 patched to build against pre-4.15 kernel headers
- App-side NIF builds no longer forced to -std=gnu99

### Removed

- Old-toolchain workarounds: af_compat package, -std=gnu99 package
  overrides, cairo optimization workarounds, erlinit sys/random.h shim,
  erlang --disable-year2038

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
