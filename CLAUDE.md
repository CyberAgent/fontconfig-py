# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**fontconfig-py** is a Python package providing Cython-based bindings to the fontconfig library. The project builds statically-linked binary wheels that bundle fontconfig and freetype, eliminating runtime dependencies for users.

**Key characteristics:**

- Cython wrapper around fontconfig C library
- Statically linked binaries (bundles fontconfig and freetype)
- Currently supports Linux and macOS
- MIT license (with bundled dependencies under FTL and fontconfig licenses)

## Architecture

### Core Components

**Cython Layer** ([src/fontconfig/](src/fontconfig/))

- `fontconfig.pyx`: Main Cython implementation exposing Python API
- `_fontconfig.pxd`: Cython declarations for fontconfig C API

**Key Python Classes:**

- `Config`: Holds fontconfig configuration (default or custom)
- `Pattern`: Represents font patterns for matching/querying
- `FontSet`: Container for lists of font patterns
- `ObjectSet`: Defines which properties to return from queries
- `Blanks`: Legacy Unicode blank character handling (deprecated)
- `CharSet`: Set of Unicode characters

**High-level API (v0.3.0+):**

Three main functions aligned with fontconfig core operations:

- `match(pattern, properties, select, config)`: Find the best matching font (wraps `FcFontMatch`)
- `sort(pattern, properties, select, trim, config)`: Get fonts sorted by match quality (wraps `FcFontSort`)
- `list(pattern, properties, select, config)`: List all matching fonts (wraps `FcFontList`)

All functions support both pattern strings (`:family=Arial:weight=200`) and properties dicts (`{"family": "Arial", "weight": 200}`).

**Deprecated:**

- `query(where, select)`: Deprecated in v0.3.0, use `list()` instead (or `match()`/`sort()` depending on use case)

### Build System

The build process is more complex than typical Python packages due to static linking:

1. **Third-party libraries** (`third_party/` as git submodules):
   - `freetype`: Font rendering engine
   - `fontconfig`: Font configuration library

2. **Build script** (`scripts/build_third_party.sh`):
   - Builds freetype statically with minimal dependencies
   - Builds fontconfig statically on top of freetype
   - Installs to `/usr/local/` (macOS) or system paths (Linux)
   - Handles platform-specific flags (universal2 for macOS)

3. **Python build** (`setup.py`):
   - Uses Cython to compile `.pyx` to C
   - Links against static fontconfig, freetype, expat, and zlib
   - Package discovery via setuptools

4. **CI/CD** (`.github/workflows/wheels.yaml`):
   - Uses cibuildwheel for multi-platform wheel building
   - Runs `build_third_party.sh` before Python build
   - Tests with pytest before uploading wheels
   - Auto-publishes to PyPI on releases

### Python Limited API and Stable ABI (v1.0.0+)

Starting with v1.0.0, fontconfig-py is built using Python's Limited API (PEP 384), providing Stable ABI wheels.

**Benefits:**

- **Forward compatibility**: Single wheel supports Python 3.10, 3.11, 3.12, 3.13, 3.14+
- **Reduced distribution**: ~75% smaller total package size (3 wheels instead of 12+)
- **Future-proof**: Works with future Python versions without rebuilding
- **Minimal overhead**: < 5% performance impact for typical font queries

**Technical Details:**

- Uses `Py_LIMITED_API=0x030A0000` (Python 3.10) in Cython build
- Wheels tagged with `.abi3` suffix for Stable ABI guarantee
- Requires Cython ≥3.0.0 and setuptools ≥61.0
- Can be disabled with `FONTCONFIG_USE_LIMITED_API=0` environment variable if needed

**Build Configuration:**

The Limited API is enabled by default in `setup.py`:

```python
# Enable Limited API (can be disabled with env var for troubleshooting)
USE_LIMITED_API = os.getenv("FONTCONFIG_USE_LIMITED_API", "1") == "1"
PY_LIMITED_API_VERSION = 0x030A0000  # Python 3.10+

define_macros = [("Py_LIMITED_API", PY_LIMITED_API_VERSION)] if USE_LIMITED_API else []
py_limited_api = USE_LIMITED_API
```

To build without Limited API (for maximum performance or troubleshooting):

```bash
FONTCONFIG_USE_LIMITED_API=0 pip install --no-binary fontconfig-py fontconfig-py
```

## Development Commands

### Environment Setup

```bash
# Install with development dependencies
uv sync --dev

# Or install docs dependencies
uv sync --group docs
```

### Building from Source

**Important:** Building requires system dependencies. You have two options:

**Option 1: Use system packages (recommended for local development):**

```bash
# macOS
brew install fontconfig freetype pkg-config

# Ubuntu/Debian
sudo apt-get install libfontconfig1-dev libfreetype6-dev pkg-config

# Then build the Python package
uv build --wheel
```

**Option 2: Build third-party libraries from source (CI environment):**

```bash
# This script builds and installs fontconfig and freetype from submodules
# Primarily intended for CI environments
bash scripts/build_third_party.sh

# Then build the Python package
uv build --wheel
```

The build script installs: gperf, gettext, uuid libraries, automake, libtool (platform-dependent).

### Testing

```bash
# Run all tests
uv run pytest tests/

# Run a single test file
uv run pytest tests/test_fontconfig.py

# Run a specific test
uv run tests/test_fontconfig.py::test_query -v
```

**Test fixtures:**

- Tests use module-scoped `config` fixture (current fontconfig config)
- Tests use `pattern` fixture (":lang=en" pattern)
- Tests use `object_set` fixture with common properties

### Code Quality

```bash
# Lint with ruff
uvx ruff check .

# Format with ruff
uvx ruff format .

# Check type hints
uv run mypy src/ tests/
```

### Documentation

```bash
# Build documentation
cd docs/
make html

# View docs
open build/html/index.html  # macOS
xdg-open build/html/index.html  # Linux
```

## Working with Cython Code

**Key patterns when editing `.pyx` files:**

1. **Memory management**: C pointers must be manually freed
   - Most wrapper classes store a `_ptr` and use `__dealloc__` to free
   - Some objects have `_owner` flag to prevent double-free

2. **Type conversions**:
   - `_ObjectToFcValue()`: Python → fontconfig value
   - `_FcValueToObject()`: fontconfig value → Python
   - String encoding: Python str ↔ UTF-8 bytes ↔ `FcChar8*`

3. **C API patterns**:
   - Most fontconfig functions start with `Fc`
   - Result codes: `FcResultMatch`, `FcResultNoMatch`, `FcResultOutOfMemory`
   - Boolean type is `FcBool` (C int, cast to Python bool)

4. **After editing `.pyx` or `.pxd` files**:

   ```bash
   # Rebuild extension
   uv sync --reinstall
   ```

## Common Patterns

### Finding the Best Font (v0.3.0+)

```python
# High-level API (recommended) - wraps FcFontMatch
font = fontconfig.match(":family=Arial:weight=200")
if font:
    print(font["file"])

# Using properties dict
font = fontconfig.match(properties={"family": "Arial", "weight": 200})

# Custom properties to return
font = fontconfig.match(":family=Arial", select=("family", "file", "weight"))
```

### Getting Sorted Font Results (v0.3.0+)

```python
# High-level API (recommended) - wraps FcFontSort
fonts = fontconfig.sort(":family=Arial")
for font in fonts[:5]:  # Top 5 matches
    print(font["family"], font["file"])

# Using properties dict
fonts = fontconfig.sort(properties={"family": "Arial"})
```

### Listing All Matching Fonts (v0.3.0+)

```python
# High-level API (recommended) - wraps FcFontList
fonts = fontconfig.list(":lang=en", select=("family", "file"))

# Using properties dict
fonts = fontconfig.list(properties={"lang": ["en"]})

# List all fonts
fonts = fontconfig.list()
```

### Low-Level API (for advanced use cases)

```python
# Direct access to Config/Pattern/ObjectSet for more control
config = fontconfig.Config.get_current()
pattern = fontconfig.Pattern.parse(":lang=en")
object_set = fontconfig.ObjectSet.create()
object_set.add("family")
fonts = config.font_list(pattern, object_set)

# Manual font matching with substitutions
pattern = fontconfig.Pattern.parse(":family=Arial")
pattern.default_substitute()
config.substitute(pattern)
matched = config.font_match(pattern)
```

## Troubleshooting

**Build failures:**

- Ensure git submodules are initialized: `git submodule update --init --recursive`
- Check system dependencies are installed (see `build_third_party.sh`)
- On macOS, ensure Xcode command line tools are installed. Also, set the following environment variables in the local environment:
  - `CC=clang`
  - `CFLAGS="-I/opt/homebrew/include -L/opt/homebrew/lib"`

**Test failures on "family=Arial":**

- These tests may fail if Arial isn't installed on the system
- Consider using more universal test fonts or system defaults

**Version mismatches:**

- Package version is in `pyproject.toml`
- `__version__` in `__init__.py` should match

## Release Process

Prerequisites: `gh` CLI (authenticated) and `uv` installed.

### Ongoing — Keep `[Unreleased]` up to date

Every pull request that makes a user-facing change should add an entry under `## [Unreleased]` in `CHANGELOG.md`. Use concise 1-2 line entries categorised under `Added`, `Changed`, `Fixed`, `Documentation`, etc. This is also enforced by the PR checklist in `.github/PULL_REQUEST_TEMPLATE.md`.

### Step 1 — Verify the `[Unreleased]` section before releasing

Confirm that `## [Unreleased]` contains entries covering everything that will ship. The release script will refuse to proceed if the section is empty.

### Step 2 — Run the release script

```bash
bash scripts/release.sh vX.Y.Z
```

The script validates preconditions (clean tree, `[Unreleased]` section present, no existing branch or tag), then:

- Creates branch `release/vX.Y.Z` from an up-to-date `main`
- Bumps `__version__` in `src/fontconfig/__init__.py`
- Moves the `[Unreleased]` content into a new `[X.Y.Z] - YYYY-MM-DD` section (keeping the `[Unreleased]` heading for the next release)
- Runs `uv sync`
- Commits, pushes, and opens a GitHub PR titled "Release vX.Y.Z"

### Step 3 — Review and merge the PR

- Wait for CI checks to pass
- Get code review approval
- Merge to `main` — **NEVER commit directly to main**

Everything after the merge is automatic: the `auto-release` workflow (`.github/workflows/auto-release.yaml`) creates the git tag and GitHub Release, which triggers `wheels.yaml` to build wheels and publish to PyPI.

**Important notes:**

- Use `release/vX.Y.Z` branch naming (the `auto-release` workflow keys on this prefix)
- Just pushing a tag does NOT trigger PyPI upload — a GitHub Release must be published
- The `release` environment in GitHub Actions may require manual approval before PyPI upload
