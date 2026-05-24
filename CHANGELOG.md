# Changelog

All notable changes to `mentionpath.nvim` should land here before release tags are cut.

Versioning:
- Use SemVer tags: `vMAJOR.MINOR.PATCH`.
- Before `v1.0.0`, treat new features and breaking changes as `MINOR` bumps.
- Keep unreleased work under `## [Unreleased]`.
- When releasing, move unreleased entries into a dated version section.

## [Unreleased]

## [v0.2.0] - 2026-05-24

This release introduces project path mentions and skill mentions for completion
sources that support Markdown and text workflows.

### Added
- Project file completion with `@path` mentions in Markdown and text buffers.
- `nvim-cmp` and `blink.cmp` source integrations for mention completions.
- Skill completion with `$trigger` for skills discovered in `.agents/skills/`.
- Skill discovery from subdirectories that contain a `SKILL.md` marker file.
- Skill completion configuration for enabling/disabling skills, changing the
  trigger, and customizing the skills directory or marker file.
- LazyVim setup documentation and release/versioning guidance.

### Fixed
- Keep mention completions active while typing.
- Resolve temp prompt buffers against the current project when the active buffer lives outside the repo.
