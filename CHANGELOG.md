# Changelog

All notable changes to `mentionpath.nvim` should land here before release tags are cut.

Versioning:
- Use SemVer tags: `vMAJOR.MINOR.PATCH`.
- Before `v1.0.0`, treat new features and breaking changes as `MINOR` bumps.
- Keep unreleased work under `## [Unreleased]`.
- When releasing, move unreleased entries into a dated version section.

## [Unreleased]

### Added
- Initial Markdown `@path` completion source for project files.
- LazyVim setup documentation.
- `$trigger` for discovering and completing skills found in `.agents/skills/` directories.
- Skills are subdirectories containing a `SKILL.md` marker file.
- `skills.enabled` config option to enable/disable skill completion.
- `skills.trigger` config option (default `$`) to customize the trigger character.
- `skills.directory` config option (default `.agents/skills`) to customize the skills directory.
- `skills.marker_file` config option (default `SKILL.md`) to customize the marker file name.

### Fixed
- Keep mention completions active while typing.
- Resolve temp prompt buffers against the current project when the active buffer lives outside the repo.

