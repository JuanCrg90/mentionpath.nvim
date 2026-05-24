# mentionpath.nvim

Inline project-file mentions for Markdown prompt writing.

Type `@controller` in a Markdown buffer, pick a project file from `blink.cmp` or `nvim-cmp`, and insert `@app/controllers/orders_controller.rb`.

Type `$rails` in a Markdown buffer, pick a registered skill from `.agents/skills/`, and insert `$rails-simplifier`.

## MVP

- Markdown and text file completion source.
- `@` trigger for project files.
- `$` trigger for agent skills.
- Continuous no-space query tokens.
- Project file discovery through `fd` when available.
- `.gitignore` respected by default through `fd`.
- Fallback to `git ls-files --cached --others --exclude-standard` when `fd` is missing.
- Temp prompt buffers still resolve against the current project when Neovim `cwd` is inside the repo.
- Token-aware matching for basenames, path segments, underscores, hyphens, and fuzzy subsequences.
- Case-insensitive matching.
- Leading slash tolerant matching, so `@/lua/` can match `lua/...`.
- Skill discovery from `.agents/skills/` directories containing `SKILL.md` marker files.

## Installation

### lazy.nvim with blink.cmp

```lua
return {
  {
    "JuanCrg90/mentionpath.nvim",
    ft = { "markdown", "text" },
    dependencies = { "saghen/blink.cmp" },
    opts = {
      ui = {
        backend = "blink",
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
      table.insert(opts.sources.default, 1, "mentionpath")

      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.mentionpath = require("mentionpath").blink_provider()
    end,
  },
}
```

`mentionpath.nvim` exposes a native blink source through `require("mentionpath").blink_provider()`. Add it to `sources.providers` and include `"mentionpath"` in `sources.default`.

### lazy.nvim with nvim-cmp

```lua
return {
  {
    "JuanCrg90/mentionpath.nvim",
    ft = { "markdown", "text" },
    dependencies = { "hrsh7th/nvim-cmp" },
    opts = {
      ui = {
        backend = "cmp",
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, 1, { name = "mentionpath" })
    end,
  },
}
```

`mentionpath.nvim` registers the `mentionpath` cmp source automatically when `nvim-cmp` is available and `ui.backend` is not `"blink"`. You still need to add the source to your Markdown and text cmp configuration.

### LazyVim

LazyVim uses `blink.cmp` by default. Add the native source provider and prepend it to the default source list:

```lua
return {
  {
    "JuanCrg90/mentionpath.nvim",
    ft = { "markdown", "text" },
    dependencies = { "saghen/blink.cmp" },
    opts = {
      ui = {
        backend = "blink",
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
      table.insert(opts.sources.default, 1, "mentionpath")

      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.mentionpath = require("mentionpath").blink_provider()
    end,
  },
}
```

For a LazyVim setup that still uses `nvim-cmp`, merge the cmp source into the existing setup:

```lua
return {
  {
    "JuanCrg90/mentionpath.nvim",
    ft = { "markdown", "text" },
    dependencies = { "hrsh7th/nvim-cmp" },
    opts = {},
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, 1, { name = "mentionpath" })
    end,
  },
}
```

The cmp source is added to the shared source list, but `mentionpath.nvim` still reports itself as unavailable outside Markdown and text buffers.

## Versioning

`mentionpath.nvim` uses Git tags as its release version source of truth.

- Cut releases with SemVer tags such as `v0.1.0`.
- Track pending user-visible changes in [CHANGELOG.md](CHANGELOG.md).
- Push a `v*` tag to trigger GitHub Release creation.

Example `lazy.nvim` pin:

```lua
{
  "JuanCrg90/mentionpath.nvim",
  version = "v0.2.0",
}
```

### Local Development

Use `dir` when working from a local checkout:

```lua
return {
  {
    "mentionpath.nvim",
    dir = "/path/to/mentionpath.nvim",
    ft = { "markdown", "text" },
    dependencies = { "hrsh7th/nvim-cmp" },
    opts = {
      debug = {
        enabled = true,
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, 1, { name = "mentionpath" })
    end,
  },
}
```

`debug.enabled = true` is useful while testing the plugin locally. The public default is `false`.

## Configuration

```lua
require("mentionpath").setup({
  min_chars = 1,
  max_results = 50,
  ui = {
    backend = "auto",
  },
  root = {
    detector = nil,
  },
  files = {
    enabled = true,
    cache_ttl_ms = 5000,
    fd_args = {
      "--type",
      "f",
      "--strip-cwd-prefix",
      "--color",
      "never",
      ".",
    },
  },
  skills = {
    enabled = true,
    trigger = "$",
    directory = ".agents/skills",
    marker_file = "SKILL.md",
    cache_ttl_ms = 5000,
  },
  debug = {
    enabled = false,
    log_path = nil,
  },
})
```

### Skills Configuration

The `skills` table controls skill discovery and completion:

| Option | Default | Description |
|--------|---------|-------------|
| `enabled` | `true` | Enable/disable skill completion |
| `trigger` | `"$"` | Character that triggers skill completion |
| `directory` | `".agents/skills"` | Subdirectory relative to project root where skills live |
| `marker_file` | `"SKILL.md"` | File that marks a skill directory as valid |
| `cache_ttl_ms` | `5000` | How long to cache discovered skills (ms) |

Skills are directories under `<project-root>/.agents/skills/<skill-name>/` that contain a `SKILL.md` marker file. When you type `$rails`, the plugin will find and suggest matching skills like `$rails-simplifier`.

## Debugging

Enable logs while testing:

```lua
require("mentionpath").setup({
  debug = {
    enabled = true,
  },
})
```

Log file:

```vim
:lua print(require("mentionpath.log").path())
```

Useful commands:

```vim
:MentionpathLog
:MentionpathClearLog
```

From a terminal, tail the log while typing in Neovim:

```sh
tail -f "$(nvim --headless -u NONE -i NONE +'lua io.write(vim.fn.stdpath("state") .. "/mentionpath.log")' +qa)"
```

## Architecture

- `mentionpath.config`: user options and defaults.
- `mentionpath.log`: optional debug logging for manual testing.
- `mentionpath.root`: project root detection, using `git rev-parse --show-toplevel` first.
  If the active buffer lives in a temp directory, it falls back to the current Neovim `cwd` project root before using the temp path itself.
- `mentionpath.files`: async file collection and short-lived per-root cache.
- `mentionpath.skills`: skill discovery from `.agents/skills/` directories.
- `mentionpath.token`: active trigger extraction (`@query` for files, `$query` for skills) from cursor context.
- `mentionpath.matcher`: simple ranking against basenames and relative paths.
- `mentionpath.source`: shared completion engine, routes to files or skills based on trigger type.
- `mentionpath.blink`: native `blink.cmp` source adapter.
- `cmp_mentionpath`: `nvim-cmp` source adapter.

The completion adapters are intentionally thin so another backend can reuse the same root, file, token, and matcher modules later.

## Implementation Flow

**File completion (via `@`):**

1. `nvim-cmp` asks the source for completions after `@` or while typing.
2. The source exits unless the current buffer filetype is `markdown` or `text`.
3. `mentionpath.token` extracts the active no-space `@query` before the cursor.
4. `mentionpath.root` finds the project root.
5. `mentionpath.files` returns a cached file list or runs `fd` from the root.
6. `mentionpath.matcher` ranks relative paths.
7. The cmp item uses `textEdit` to replace only the active token with `@relative/path`.
8. Results are marked incomplete so cmp re-queries as the mention text changes.

**Skill completion (via `$`):**

1. `nvim-cmp` asks the source for completions after `$` or while typing.
2. The source exits unless the current buffer filetype is `markdown` or `text`.
3. `mentionpath.token` extracts the active no-space `$query` before the cursor.
4. `mentionpath.root` finds the project root.
5. `mentionpath.skills` scans `.agents/skills/` for subdirectories containing `SKILL.md`.
6. `mentionpath.matcher` ranks skill names.
7. The cmp item uses `textEdit` to replace only the active token with `$skill-name`.
8. Results are marked incomplete so cmp re-queries as the mention text changes.

## Notes

Install `fd` for the intended file discovery behavior:

```sh
brew install fd
```

Without `fd`, the plugin falls back to Git-tracked and untracked non-ignored files.
