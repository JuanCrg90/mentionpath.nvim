# Repository Guidelines

## Project Structure & Module Organization

Core plugin code lives in `lua/mentionpath/`. Keep root detection, file discovery, token parsing, matching, and logging isolated by module. The `nvim-cmp` adapter lives in `lua/cmp_mentionpath/`, and `after/plugin/mentionpath.lua` handles automatic source registration on startup. Manual test entrypoints live in `tests/`. User-facing docs belong in `README.md` and `docs/`.

## Build, Test, and Development Commands

This plugin has no build step; use headless Neovim for verification.

```sh
nvim --headless -u NONE -i NONE -c 'set rtp+=.' -c 'luafile tests/minimal.lua' -c qa
```

Runs token and matcher coverage.

```sh
nvim --headless -u NONE -i NONE -c 'set rtp+=.' -c 'luafile tests/cmp_source.lua'
```

Exercises the `nvim-cmp` source end to end and exits from the test file. For manual debugging, enable `debug.enabled = true` and inspect `:MentionpathLog`. Install `fd` for the intended file scan path; otherwise the plugin falls back to `git ls-files`.

## Coding Style & Naming Conventions

Use Lua with two-space indentation. Prefer small, single-purpose modules and local helper functions. Export module APIs through a local `M` table. File names use snake_case, for example `root.lua` or `cmp_source.lua`. Keep user options centralized in `lua/mentionpath/config.lua`; avoid hardcoding defaults in multiple places.

## Testing Guidelines

Add or update a regression test for behavior changes when practical. Keep tests close to user-visible behavior: token extraction, ranking order, root detection, and completion text edits. Follow the existing plain-Lua assertion style in `tests/*.lua`. Name new test files after the feature under test, for example `tests/root.lua`.

## Commit & Pull Request Guidelines

Use Conventional Commits, as in `feat: add markdown file mention completion` or `fix: keep mention completions active while typing`. PRs should explain the behavior change, list the verification commands you ran, and note any manual Neovim setup needed to reproduce. Include screenshots or short terminal output only when UI behavior or ranking changes would be hard to review from code alone.
