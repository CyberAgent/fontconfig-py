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
#   - A 'draft-next' draft release created by the release-drafter workflow
#
# The script:
#   1. Validates preconditions (clean tree, draft-next release exists, no existing branch)
#   2. Creates branch release/vX.Y.Z from an up-to-date main
#   3. Bumps __version__ in src/fontconfig/__init__.py
#   4. Writes draft-next release notes into a new versioned CHANGELOG section
#   5. Runs uv sync to update the lock file
#   6. Commits, pushes, and opens a GitHub PR (labeled skip-changelog)

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

# draft-next release must exist and contain at least one real entry
echo "Fetching release notes from draft-next draft..."
_DRAFT_STDERR=$(mktemp)
if ! DRAFT_BODY=$(gh release view "draft-next" --json body --jq '.body' 2>"$_DRAFT_STDERR"); then
    _DRAFT_ERROR=$(cat "$_DRAFT_STDERR"); rm -f "$_DRAFT_STDERR"
    die "Failed to read 'draft-next' draft release: ${_DRAFT_ERROR}"
fi
rm -f "$_DRAFT_STDERR"
DRAFT_BODY_TRIMMED=$(printf '%s' "$DRAFT_BODY" | tr -d '[:space:]')
if [[ -z "$DRAFT_BODY_TRIMMED" ]]; then
    die "'draft-next' draft release body is empty. Merge a PR with a release label first so release-drafter can generate notes, then try again."
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
# Update CHANGELOG.md from draft-next release notes (use Python for cross-platform safety)
# ---------------------------------------------------------------------------

echo "Updating CHANGELOG.md from draft release notes..."
python3 - "$VERSION" "$TODAY" "$DRAFT_BODY" <<'PYEOF'
import re, sys

version, today, draft_body = sys.argv[1], sys.argv[2], sys.argv[3]
path = "CHANGELOG.md"

with open(path) as f:
    content = f.read()

# Match the entire [Unreleased] block: heading + body up to the next ## heading
pattern = re.compile(
    r"(## \[Unreleased\][^\n]*\n)"  # group 1: heading line
    r"(.*?)"                         # group 2: existing body (cleared)
    r"(?=^## \[|\Z)",                # lookahead: next versioned heading or EOF
    re.DOTALL | re.MULTILINE,
)
m = pattern.search(content)
if not m:
    print("Error: could not locate [Unreleased] block in CHANGELOG.md", file=sys.stderr)
    sys.exit(1)

# Replace: keep [Unreleased] heading (empty), then insert new versioned section
versioned_section = f"## [{version}] - {today}\n\n{draft_body.strip()}\n\n"
replacement = m.group(1) + "\n" + versioned_section
new_content = content[: m.start()] + replacement + content[m.end() :]

with open(path, "w") as f:
    f.write(new_content)

print(f"  CHANGELOG.md: inserted ## [{version}] - {today}")
PYEOF

# ---------------------------------------------------------------------------
# Update lock file
# ---------------------------------------------------------------------------

echo "Running uv sync..."
# On macOS with Homebrew, the compiler cannot find fontconfig/freetype headers
# unless the flags are passed explicitly.  Use pkg-config when available so the
# command is portable and does not hard-code Homebrew paths.
if command -v pkg-config &>/dev/null && pkg-config --exists fontconfig freetype2 2>/dev/null; then
    CFLAGS="$(pkg-config --cflags fontconfig freetype2) ${CFLAGS:-}" \
    LDFLAGS="$(pkg-config --libs fontconfig freetype2) ${LDFLAGS:-}" \
    uv sync
else
    if [[ "$(uname -s)" == "Darwin" ]]; then
        echo "Warning: pkg-config metadata for fontconfig/freetype2 not found." >&2
        echo "  uv sync may fail. If it does, install the missing packages with:" >&2
        echo "    brew install pkg-config fontconfig freetype" >&2
    fi
    uv sync
fi

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
    --label "skip-changelog" \
    --body "$(cat <<EOF
## Release v${VERSION}

See [CHANGELOG.md](CHANGELOG.md) for details.

## Checklist

- [ ] Version bumped in \`src/fontconfig/__init__.py\`
- [ ] CHANGELOG updated with release date
- [ ] CI checks pass
- [ ] Code review approved

After merging, the \`auto-release\` workflow creates the tag and GitHub Release, then dispatches \`wheels.yaml\` to build the wheels.

**The PyPI upload then waits for you.** The \`pypi-publish\` job runs in the \`release\` environment, which requires approval from the \`fontconfig-py-maintainer\` team — approve the pending deployment from the run's page in the Actions tab. Nothing reaches PyPI until you do.
EOF
)"

echo ""
echo "Done. Release PR for v${VERSION} is open."
echo "After it is merged, the tag, Release, and wheel build happen automatically."
echo "The PyPI upload then waits for your approval of the 'release' environment"
echo "deployment -- watch for it in the Actions tab."
