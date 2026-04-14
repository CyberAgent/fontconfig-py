# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] - 2025-12-23

### Changed

- Add PyPI package classifiers for development status, topics, and Python versions (#52)
- Add package keywords for improved discoverability (#52)
- Consolidate development dependencies to dependency-groups format (#51)

### Documentation

- Update security policy to clarify v1.0+ support (#50)
- Add community standards documentation (CODE_OF_CONDUCT, CONTRIBUTING, SECURITY) (#46)
- Reorganize documentation by topics for better navigation (#45)
- Expand README with fontconfig explanation (#44)
- Clarify bundled dependencies in NOTICE (#46)

### Infrastructure

- Transfer copyright to CyberAgent, Inc. (#42)
- Fix workflow permissions for code scanning (#43)
- Update GitHub Actions dependencies (checkout v6, upload-artifact v6, download-artifact v7) (#47-49)

## [1.0.0] - 2025-12-10

### Breaking Changes

- Dropped Python 3.9 support (EOL October 2025); minimum version now 3.10

### Changed

- Build wheels using Python Limited API (Stable ABI) for forward compatibility across Python 3.10-3.14+
- Distribution size reduced by ~75%; minimal performance impact (<5%)

### Technical

- Enabled Py_LIMITED_API with abi3 wheels for Stable ABI guarantee

## [0.4.0] - 2025-12-08

### Added

- Pythonic CharSet support with factory methods, modification/inspection methods, and iteration support
- CharSet integration with fontconfig queries with auto-conversion from strings and codepoints

### Documentation

- Add beginner-friendly cookbook with 8 common font search patterns
- Add error handling, character sets, and pattern syntax documentation with 800+ lines of practical examples

## [0.3.1] - 2025-12-08

### Fixed

- Fix TypeError when using single integer/float values for range properties; auto-convert to ranges (#36)

### Changed

- Implement single-source versioning from `__init__.py`

### Documentation

- Update README with modern API examples and improved structure

## [0.3.0] - 2025-11-26

### Added

- Add high-level API functions `match()`, `sort()`, and `list()` aligned with fontconfig core operations
- Add properties dict parameter support for all functions (alternative to pattern strings)

### Deprecated

- Deprecate `query()` function in favor of `match()`, `sort()`, or `list()`

### Documentation

- Add usage documentation with function selection guidance and migration guide from `query()`

## [0.2.1] - 2025-11-25

### Fixed

- Fixed fontconfig build paths and added Homebrew check for macOS compatibility
- Fixed _FcSetName enum import warning

### Documentation

- Expanded usage documentation with comprehensive examples
- Improved API documentation and usage patterns

## [0.2.0] - 2024-01-XX

### Added

- Type hint support with mypy and stub files
- CLAUDE.md documentation for Claude Code integration

### Changed

- Migrated from Poetry to uv package manager
- Updated build system and fixed build issues

### Fixed

- Fixed license notice for bundled freetype

## [0.1.3] - 2024-XX-XX

### Fixed

- License updates for bundled dependencies

## Earlier Versions

See git history for changes in versions prior to 0.1.3.
