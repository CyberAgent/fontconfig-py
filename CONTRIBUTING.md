# Contributing to fontconfig-py

Thank you for your interest in contributing to fontconfig-py! We welcome contributions from the community.

This document provides guidelines for contributing to the project. By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Submitting Changes](#submitting-changes)
- [Release Process](#release-process)
- [Reporting Issues](#reporting-issues)
- [Documentation](#documentation)
- [Code Style](#code-style)
- [Questions and Support](#questions-and-support)

## Getting Started

### Prerequisites

Building fontconfig-py from source requires:

- Python 3.10 or later
- [uv](https://github.com/astral-sh/uv) for dependency management
- C compiler (gcc, clang, or MSVC)
- Git with submodule support

**System dependencies:**

You can use your system package manager to install fontconfig and freetype (recommended for local development), or build them from source using the provided script (primarily for CI environments).

**macOS users**: You'll need to set these environment variables:

```bash
export CC=clang
export CFLAGS="-I/opt/homebrew/include -L/opt/homebrew/lib"
```

### Setting Up Your Development Environment

1. **Fork and clone the repository:**

   ```bash
   git clone https://github.com/YOUR_USERNAME/fontconfig-py.git
   cd fontconfig-py
   ```

2. **Install system dependencies:**

   **Option A: Use system packages (recommended):**

   ```bash
   # macOS
   brew install fontconfig freetype pkg-config

   # Ubuntu/Debian
   sudo apt-get install libfontconfig1-dev libfreetype6-dev pkg-config

   # Fedora/RHEL/CentOS
   sudo dnf install fontconfig-devel freetype-devel pkgconfig
   ```

   **Option B: Build from source (CI environment):**

   ```bash
   # First, clone with submodules (if you didn't use --recurse-submodules)
   git submodule update --init --recursive

   # Build and install fontconfig and freetype from submodules
   bash scripts/build_third_party.sh
   ```

   **Note**: Option B can take several minutes and requires additional build tools (gperf, gettext, uuid libraries, automake, libtool).

3. **Install Python development dependencies:**

   ```bash
   uv sync --dev
   ```

4. **Build the Python extension:**

   ```bash
   uv build --wheel
   ```

   Or for development installation:

   ```bash
   uv sync --reinstall
   ```

## Development Workflow

### Running Tests

Run all tests with pytest:

```bash
uv run pytest tests/
```

Run a specific test file:

```bash
uv run pytest tests/test_fontconfig.py
```

Run a specific test with verbose output:

```bash
uv run pytest tests/test_fontconfig.py::test_query -v
```

### Code Quality Checks

We use several tools to maintain code quality:

**Linting with Ruff:**

```bash
uvx ruff check .
```

**Formatting with Ruff:**

```bash
uvx ruff format .
```

**Type checking with mypy:**

```bash
uv run mypy src/ tests/
```

**Run all checks before submitting:**

```bash
uvx ruff check . && uvx ruff format . && uv run mypy src/ tests/ && uv run pytest tests/
```

### Working with Cython Code

The core library is written in Cython (`.pyx` files). Key considerations:

- **Memory management**: C pointers must be manually freed (use `__dealloc__`)
- **Type conversions**: Helper functions handle Python ↔ C conversions
- **String encoding**: Python str ↔ UTF-8 bytes ↔ `FcChar8*`
- **After editing `.pyx` or `.pxd` files**: Rebuild with `uv sync --reinstall`

For detailed information about the codebase architecture, internal APIs, and advanced patterns, see [CLAUDE.md](CLAUDE.md).

## Submitting Changes

### Branch Naming

Use descriptive branch names with prefixes:

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions or modifications

Example: `feature/add-charset-comparison` or `fix/memory-leak-in-pattern`

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) format:

```text
type: brief description

Optional longer description explaining the change in more detail.
```

**Types:**

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `refactor:` - Code refactoring without functionality changes
- `test:` - Test additions or modifications
- `ci:` - CI/CD pipeline changes
- `deps:` - Dependency updates

**Examples:**

```text
docs: Add explanation of what fontconfig is to README

fix: Resolve memory leak in Pattern deallocation

feat: Add CharSet support for Unicode character sets
```

### Pull Request Process

1. **Create a feature branch** from `main`
2. **Make your changes** following the code style guidelines
3. **Add or update tests** for your changes
4. **Update documentation** if you're changing user-facing functionality
5. **Update CHANGELOG.md** following [Keep a Changelog](https://keepachangelog.com/) format for user-facing changes
6. **Run all tests and quality checks** (linting, formatting, type checking)
7. **Push your branch** and create a pull request

### Pull Request Guidelines

- Fill out the pull request template completely
- Link any related issues
- Ensure all CI checks pass
- Respond to code review feedback promptly
- Keep pull requests focused on a single change
- Squash commits if requested by maintainers

### Code Review

- All pull requests require review before merging
- Maintainers will provide constructive feedback
- Be open to suggestions and willing to make changes
- Reviews may take a few days depending on complexity

## Release Process

**Note**: This section is for maintainers. Contributors should focus on submitting pull requests for features and fixes.

Prerequisites: `gh` CLI (authenticated) and `uv` installed.

### Creating a Release

1. **Keep `CHANGELOG.md` up to date** as development proceeds — add entries under `## [Unreleased]` for each notable change.

2. **Run the release script**:

   ```bash
   bash scripts/release.sh vX.Y.Z
   ```

   This creates the `release/vX.Y.Z` branch, bumps the version, updates `CHANGELOG.md`, runs `uv sync`, and opens a PR automatically.

3. **Review and merge the PR** — wait for CI, get approval, then merge to `main`. The `auto-release` workflow then creates the git tag and GitHub Release and dispatches the wheel build (a Release created by `GITHUB_TOKEN` does not trigger workflows on its own).

4. **Approve the PyPI upload** — the upload runs in the `release` environment, which requires maintainer approval, so the run pauses after the wheels build. Approve the pending deployment in the Actions tab to publish.

### Important Notes

- NEVER commit directly to main — always use a pull request
- Use `release/vX.Y.Z` branch naming (the automation keys on this prefix)
- See [CLAUDE.md](CLAUDE.md) for full technical documentation

## Reporting Issues

### Bug Reports

If you find a bug, please [create an issue](https://github.com/kyamagu/fontconfig-py/issues/new/choose) using the bug report template.

Include:

- fontconfig-py version
- Python version
- Operating system
- Steps to reproduce
- Expected vs. actual behavior
- Error messages or logs

### Feature Requests

For new features, use the feature request template. Explain:

- The problem you're trying to solve
- Your proposed solution
- Alternative approaches you've considered
- Whether you're willing to implement it

### Security Vulnerabilities

**Do not open public issues for security vulnerabilities.** Instead, please see our [Security Policy](SECURITY.md) for responsible disclosure instructions.

## Documentation

### Building Documentation

The project uses Sphinx for documentation:

```bash
cd docs/
make html
```

View the built documentation:

```bash
# macOS
open build/html/index.html

# Linux
xdg-open build/html/index.html
```

### Documentation Standards

- Use clear, concise language
- Include code examples for new features
- Update API documentation when changing function signatures
- Follow the existing documentation structure and style

## Code Style

### Python Code

- Follow PEP 8 (enforced by Ruff)
- Use type hints for all functions and methods
- Write docstrings for public APIs (Google style)
- Keep functions focused and concise

### Cython Code

- Match the existing code style in `.pyx` files
- Document complex memory management patterns
- Use appropriate error handling for C API calls
- Prefer Python types in public APIs, use C types internally

### Testing

- Write tests for all new functionality
- Maintain or improve code coverage
- Use descriptive test names
- Include both positive and negative test cases

## Questions and Support

### Where to Get Help

- **General questions**: Open an issue with the "question" label
- **Bug reports**: Use the bug report issue template
- **Feature discussions**: Use the feature request template
- **Security issues**: See [SECURITY.md](SECURITY.md)

### Response Time

We aim to respond to issues and pull requests within a few days. Please be patient, as this is a volunteer-maintained project.

## License

By contributing to fontconfig-py, you agree that your contributions will be licensed under the [MIT License](LICENSE).

---

Thank you for contributing to fontconfig-py! Your efforts help make font handling in Python better for everyone.
