#!/usr/bin/env bash
# Release preparation script for fontconfig-py.
#
# Usage:
#   scripts/release.sh <version>
#
# Example:
#   scripts/release.sh 1.0.2
#   scripts/release.sh v1.0.2
#
# Prerequisites:
#   - gh CLI (https://cli.github.com/) installed and authenticated
#   - uv installed (https://docs.astral.sh/uv/)
#   - Git remote "origin" pointing to the GitHub repo
#
# The script:
#   1. Validates preconditions (clean tree, [Unreleased] in CHANGELOG, no existing branch)
#   2. Creates branch release/vX.Y.Z from an up-to-date main
#   3. Bumps __version__ in src/fontconfig/__init__.py
#   4. Moves CHANGELOG [Unreleased] content into a new versioned section (keeps [Unreleased] heading)
#   5. Runs uv sync to update the lock file
#   6. Commits, pushes, and opens a GitHub PR

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

die() {
    echo "Error: $*" >&2
    exit 1
}

usage() {
    echo "Usage: $(basename "$0") <version>"
    echo "  version  Semver string, e.g. 1.0.2 or v1.0.2"
}

# ---------------------------------------------------------------------------
# Parse and validate version argument
# ---------------------------------------------------------------------------

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

VERSION="${1#v}"  # strip leading 'v' if present

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    die "Invalid version '${VERSION}'. Expected format: X.Y.Z"
fi

BRANCH="release/v${VERSION}"
TAG="v${VERSION}"
TODAY=$(date +%Y-%m-%d)

# ---------------------------------------------------------------------------
# Precondition checks (before touching anything)
# ---------------------------------------------------------------------------

echo "Checking prerequisites..."

# gh CLI available and authenticated
if ! command -v gh &>/dev/null; then
    die "'gh' CLI is not installed. See https://cli.github.com/"
fi
if ! gh auth status &>/dev/null; then
    die "'gh' is not authenticated. Run: gh auth login"
fi

# uv available
if ! command -v uv &>/dev/null; then
    die "'uv' is not installed. See https://docs.astral.sh/uv/"
fi

# Clean working tree
if ! git diff --quiet || ! git diff --cached --quiet; then
    die "Working tree has uncommitted changes. Commit or stash them first."
fi

# CHANGELOG has [Unreleased] section
if ! grep -q "^## \[Unreleased\]" CHANGELOG.md; then
    die "CHANGELOG.md has no '## [Unreleased]' section. Add one before releasing."
fi

# [Unreleased] section has content
UNRELEASED_BODY=$(python3 -c "
import re
with open('CHANGELOG.md') as f:
    content = f.read()
m = re.search(r'## \[Unreleased\][^\n]*\n(.*?)(?=^## \[)', content, re.DOTALL | re.MULTILINE)
print(m.group(1).strip() if m else '')
")
if [[ -z "$UNRELEASED_BODY" ]]; then
    die "The [Unreleased] section in CHANGELOG.md is empty. Add entries describing what changed before releasing."
fi

# Version heading does not already exist
if grep -q "^## \[${VERSION}\]" CHANGELOG.md; then
    die "CHANGELOG.md already has a section for [${VERSION}]."
fi

# Branch does not already exist locally
if git rev-parse --verify "$BRANCH" &>/dev/null; then
    die "Branch '${BRANCH}' already exists locally."
fi

# Branch does not already exist on remote
if git ls-remote --exit-code origin "refs/heads/${BRANCH}" &>/dev/null; then
    die "Branch '${BRANCH}' already exists on remote."
fi

# Tag does not already exist
if git ls-remote --exit-code origin "refs/tags/${TAG}" &>/dev/null; then
    die "Tag '${TAG}' already exists on remote."
fi

echo "All checks passed."

# ---------------------------------------------------------------------------
# Create release branch
# ---------------------------------------------------------------------------

echo "Switching to main and pulling latest..."
git checkout main
git pull origin main

echo "Creating branch ${BRANCH}..."
git checkout -b "$BRANCH"

# ---------------------------------------------------------------------------
# Bump version in __init__.py (use Python for cross-platform safety)
# ---------------------------------------------------------------------------

echo "Bumping version to ${VERSION}..."
python3 - "$VERSION" <<'PYEOF'
import re, sys

version = sys.argv[1]
path = "src/fontconfig/__init__.py"

with open(path) as f:
    content = f.read()

new_content = re.sub(
    r'__version__ = "[^"]+"',
    f'__version__ = "{version}"',
    content,
    count=1,
)

if new_content == content:
    print(f"Warning: __version__ pattern not found in {path}", file=sys.stderr)
    sys.exit(1)

with open(path, "w") as f:
    f.write(new_content)

print(f"  {path}: set __version__ = \"{version}\"")
PYEOF

# ---------------------------------------------------------------------------
# Update CHANGELOG.md (use Python for cross-platform safety)
# ---------------------------------------------------------------------------

echo "Updating CHANGELOG.md..."
python3 - "$VERSION" "$TODAY" <<'PYEOF'
import re, sys

version, today = sys.argv[1], sys.argv[2]
path = "CHANGELOG.md"

with open(path) as f:
    content = f.read()

# Match the [Unreleased] block: heading + optional body up to the next ## heading
pattern = re.compile(
    r"(## \[Unreleased\][^\n]*\n)"   # group 1: the heading line
    r"(.*?)"                          # group 2: body (may be empty)
    r"(?=^## \[)",                    # lookahead: next version heading
    re.DOTALL | re.MULTILINE,
)

m = pattern.search(content)
if not m:
    print("Error: could not locate [Unreleased] block in CHANGELOG.md", file=sys.stderr)
    sys.exit(1)

unreleased_heading = m.group(1)  # "## [Unreleased]\n"
unreleased_body = m.group(2)     # content between headings

# Build replacement: keep [Unreleased] (empty), insert new versioned section
versioned_section = f"## [{version}] - {today}\n{unreleased_body}"
replacement = unreleased_heading + "\n" + versioned_section

new_content = content[: m.start()] + replacement + content[m.end() :]

with open(path, "w") as f:
    f.write(new_content)

print(f"  CHANGELOG.md: inserted ## [{version}] - {today}")
PYEOF

# ---------------------------------------------------------------------------
# Update lock file
# ---------------------------------------------------------------------------

echo "Running uv sync..."
uv sync

# ---------------------------------------------------------------------------
# Commit, push, open PR
# ---------------------------------------------------------------------------

echo "Committing changes..."
git add src/fontconfig/__init__.py CHANGELOG.md uv.lock
git commit -m "Bump version to ${VERSION}"

echo "Pushing branch..."
git push -u origin "$BRANCH"

echo "Creating pull request..."
gh pr create \
    --title "Release v${VERSION}" \
    --body "$(cat <<EOF
## Release v${VERSION}

See [CHANGELOG.md](CHANGELOG.md) for details.

## Checklist

- [ ] Version bumped in \`src/fontconfig/__init__.py\`
- [ ] CHANGELOG updated with release date
- [ ] CI checks pass
- [ ] Code review approved

After merging, the tag and GitHub Release are created automatically by the \`auto-release\` workflow, which then triggers the wheel build and PyPI publish.
EOF
)"

echo ""
echo "Done. Release PR for v${VERSION} is open."
echo "After it is merged, the rest of the release happens automatically."
