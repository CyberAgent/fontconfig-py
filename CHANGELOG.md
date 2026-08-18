# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.3] - 2026-08-18

> **Note:** 1.0.2 was tagged but never published to PyPI due to a CI issue (fixed in #109). Its changes are included in this release, so PyPI users upgrade directly from 1.0.1 to 1.0.3.

### Infrastructure

- Stop release-drafter doubling the category headings (#110)
- Dispatch wheels.yaml from auto-release so PyPI upload runs (#109)
- deps(deps-dev): update ruff requirement from >=0.16.1 to >=0.16.3 (#108)
- deps(deps-dev): update setuptools requirement from >=83.0.0 to >=84.0.0 (#107)
- ci(deps): bump pypa/cibuildwheel from 4.1.1 to 4.2.0 (#105)
- deps(deps-dev): update ruff requirement from >=0.16.0 to >=0.16.1 (#104)
- deps(deps-dev): update ruff requirement from >=0.15.21 to >=0.16.0 (#103)
- deps(deps-dev): update cython requirement from >=3.2.8 to >=3.2.9 (#102)
- ci(deps): bump pypa/cibuildwheel from 4.1.0 to 4.1.1 (#101)
- Fix macOS universal2 wheel build broken by json-c on runner image (#100)
- deps(deps-dev): update ruff requirement from >=0.15.20 to >=0.15.21 (#98)
- deps(deps-dev): update mypy requirement from >=2.1.0 to >=2.3.0 (#97)
- deps(deps-dev): update cython requirement from >=3.2.6 to >=3.2.8 (#96)
- deps(deps-dev): update setuptools requirement from >=82.0.1 to >=83.0.0 (#95)
- deps(deps-dev): update ruff requirement from >=0.15.17 to >=0.15.20 (#94)
- deps(deps-dev): update cython requirement from >=3.2.5 to >=3.2.6 (#93)
- ci(deps): Bump pypa/cibuildwheel from 3.4.1 to 4.1.0 (#88)
- deps(deps-dev): Update ruff requirement from >=0.15.16 to >=0.15.17 (#90)
- deps(deps-dev): Update pytest requirement from >=9.1.0 to >=9.1.1 (#92)
- ci(deps): Bump actions/checkout from 6 to 7 (#91)
- deps(deps-dev): Update pytest requirement from >=9.0.3 to >=9.1.0 (#89)
- deps(deps-dev): Update ruff requirement from >=0.15.15 to >=0.15.16 (#87)
- deps(deps-dev): Update ruff requirement from >=0.15.14 to >=0.15.15 (#85)
- deps(deps-dev): Update cython requirement from >=3.2.4 to >=3.2.5 (#84)
- deps(deps-dev): Update ruff requirement from >=0.15.13 to >=0.15.14 (#83)
- chore(deps): Bump idna from 3.10 to 3.15 in the uv group across 1 directory (#82)
- deps(deps-dev): update ruff requirement from >=0.15.12 to >=0.15.13 (#81)
- deps(deps-dev): update mypy requirement from >=1.20.2 to >=2.1.0 (#80)
- Bump urllib3 from 2.6.3 to 2.7.0 in the uv group across 1 directory (#79)
- deps(deps-dev): update ruff requirement from >=0.15.11 to >=0.15.12 (#78)
- deps(deps-dev): update mypy requirement from >=1.20.1 to >=1.20.2 (#77)
- deps(deps-dev): update ruff requirement from >=0.15.10 to >=0.15.11 (#76)
- ci(deps): bump release-drafter/release-drafter from 6 to 7 (#75)
- Bump Pygments to 2.20.0 to fix ReDoS vulnerability (#74)
- Fix uv sync on macOS by passing pkg-config flags (#73)

## [1.0.2] - 2026-04-14

- Add automated release tooling (#70)
- docs: add section on configuring fontconfig search paths (#60)

### Infrastructure

- deps(deps-dev): update mypy requirement from >=1.18.2 to >=1.20.1 (#66)
- deps(deps-dev): update cython requirement from >=3.0.0 to >=3.2.4 (#67)
- deps(deps-dev): update pytest requirement from >=8.0 to >=9.0.3 (#68)
- Bump pytest from 8.4.1 to 9.0.3 in the uv group across 1 directory (#69)
- deps(deps-dev): update sphinx requirement from >=7.0 to >=8.1.3 (#64)
- deps(deps-dev): update sphinx-rtd-theme requirement from >=3.0 to >=3.1.0 (#65)
- deps(deps-dev): update ruff requirement from >=0.4 to >=0.15.10 (#63)
- deps(deps-dev): update setuptools requirement from >=61.0 to >=82.0.1 (#62)
- ci(deps): bump pypa/cibuildwheel from 3.4.0 to 3.4.1 (#61)
- Bump requests from 2.32.4 to 2.33.0 in the uv group across 1 directory (#59)
- ci(deps): bump pypa/cibuildwheel from 3.3.1 to 3.4.0 (#58)
- Bump urllib3 from 2.5.0 to 2.6.3 (#57)
- ci(deps): bump actions/download-artifact from 7 to 8 (#56)
- ci(deps): bump actions/upload-artifact from 6 to 7 (#55)
- ci(deps): bump pypa/cibuildwheel from 3.3.0 to 3.3.1 (#54)

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
