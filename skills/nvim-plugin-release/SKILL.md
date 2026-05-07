---
name: nvim-plugin-release
description: Use when working on a Neovim plugin and the user asks to bump the version, update release notes, prepare a tag, or decide the next release number after a feature or fix.
---

# Neovim Plugin Release

Use this skill for release bookkeeping in Neovim plugin repos that version by Git tags instead of a package manifest.

## Goals

- choose the next tag with a small, explicit SemVer decision
- keep `CHANGELOG.md` current on every user-visible change
- prepare a clean release commit before tagging

## Version rules

- If there are no tags yet, start at `v0.1.0`.
- Bug fix only: bump `PATCH`.
- New backward-compatible feature: bump `MINOR`.
- Breaking change before `v1.0.0`: bump `MINOR`.
- Breaking change at or after `v1.0.0`: bump `MAJOR`.

## Workflow

1. Inspect `git status --short`, `git tag`, and the pending diff.
2. Classify the change:
   - fix
   - feature
   - breaking change
3. Compute the next tag from the latest `v*` tag.
4. Update `CHANGELOG.md`:
   - keep new work under `## [Unreleased]`
   - use `Added`, `Changed`, `Fixed`, `Removed` as needed
   - write user-visible behavior, not implementation trivia
5. If the user is preparing an actual release:
   - move `Unreleased` entries into `## [vX.Y.Z] - YYYY-MM-DD`
   - leave a fresh empty `## [Unreleased]` section at the top
   - create an annotated tag only after the release commit is ready
6. Mention the exact validation commands that were run.

## Output expectations

- State the recommended next tag explicitly.
- Explain the bump in one short sentence.
- Call out release blockers, such as missing changelog entries or unverified behavior.

## Repo conventions

- Prefer tags as the source of truth for plugin versions.
- Keep release notes human-curated in `CHANGELOG.md`.
- GitHub Releases may be generated from tags, but `CHANGELOG.md` stays canonical.

