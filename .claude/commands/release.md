Execute the release workflow for fontconfig-py. Follow every step below in order.

## Step 1 — Read current version

Read `src/fontconfig/__init__.py` and extract `__version__`.

## Step 2 — Validate CHANGELOG

Read `CHANGELOG.md`. Find the `## [Unreleased]` section (everything between that heading and the next `## [` heading). If it contains no non-whitespace content, stop and tell the user:

> The `[Unreleased]` section in CHANGELOG.md is empty. Please add content describing what changed before running a release.

## Step 3 — Determine the target version

**If `$ARGUMENTS` is provided:** trim any surrounding whitespace. If it does not match `(?:v)?\d+\.\d+\.\d+`, tell the user the format must be `X.Y.Z` or `vX.Y.Z` and stop.

**If `$ARGUMENTS` is empty:** infer the next version from the `[Unreleased]` section headings and the current version:

- Any `### Breaking Changes` heading → **major** bump (`X+1.0.0`)
- Any `### Added` heading (no breaking changes) → **minor** bump (`x.Y+1.0`)
- Any `### Changed` heading with no `Added` or `Breaking Changes` → **ambiguous** — tell the user "Changed entries could indicate a minor or patch release" and ask them to confirm which bump type to use before proceeding.
- Only `### Fixed`, `### Documentation`, `### Infrastructure`, or `### Technical` headings → **patch** bump (`x.y.Z+1`)

Present the suggested version (e.g. "Suggested version: **v1.0.2** (patch bump)") and ask the user to confirm with a simple yes/no or an alternative version before continuing.

## Step 4 — Run the release script

Once the version is confirmed, run:

```bash
bash scripts/release.sh <VERSION>
```

Capture stdout and stderr. If the script exits non-zero, surface the error message and offer remediation advice:

- `branch release/v<VERSION> already exists` → delete the branch with `git branch -d release/v<VERSION>` and retry, or choose a different version.
- `tag v<VERSION> already exists` → choose a different version.
- `already present in CHANGELOG` → choose a different version.
- Any other error → show the raw error and suggest the user investigate.

## Step 5 — Report success

On a zero exit, extract the pull request URL from the script output (look for a line containing `https://github.com/`) and display it prominently.

Then summarise next steps:

1. **Wait for CI checks** to pass on the PR (wheels build + tests on 3 platforms).
2. **Review and merge the PR** via GitHub — never commit directly to `main`.
3. **Auto-release fires automatically** after merge: `auto-release.yaml` creates the git tag and GitHub Release.
4. **Wheels are built and published** by `wheels.yaml` triggered by the GitHub Release.
5. **Manual approval required:** the `release` environment in GitHub Actions gates the PyPI upload — watch for an approval request in the Actions UI and approve it.
6. **Verify publication** once complete: `pip index versions fontconfig-py`
