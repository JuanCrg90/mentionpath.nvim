# mentionpath.nvim

Inline project-file mentions for Markdown prompt writing.

Type `@controller` in a Markdown buffer, pick a project file from `nvim-cmp`, and insert `@app/controllers/orders_controller.rb`.

## MVP

- Markdown-only completion source.
- `@` trigger.
- Continuous no-space query tokens.
- Project file discovery through `fd` when available.
- `.gitignore` respected by default through `fd`.
- Fallback to `git ls-files --cached --others --exclude-standard` when `fd` is missing.
- Temp prompt buffers still resolve against the current project when Neovim `cwd` is inside the repo.
- Token-aware matching for basenames, path segments, underscores, hyphens, and fuzzy subsequences.
- Case-insensitive matching.
- Leading slash tolerant matching, so `@/lua/` can match `lua/...`.

## Installation

### lazy.nvim

```lua
{
  "JuanCrg90/mentionpath.nvim",
  dependencies = { "hrsh7th/nvim-cmp" },
  config = function()
    require("mentionpath").setup()

    local cmp = require("cmp")

    cmp.setup.filetype("markdown", {
      sources = cmp.config.sources({
        { name = "mentionpath" },
      }, {
        { name = "buffer" },
      }),
    })
  end,
}
```

`mentionpath.nvim` registers the `mentionpath` cmp source automatically when `nvim-cmp` is available. You still need to add the source to your Markdown cmp configuration.

### LazyVim

LazyVim users can add a plugin spec that lets LazyVim merge the cmp source into the existing `nvim-cmp` setup:

```lua
return {
  {
    "JuanCrg90/mentionpath.nvim",
    ft = "markdown",
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

The cmp source is added to the shared source list, but `mentionpath.nvim` still reports itself as unavailable outside Markdown buffers.

## Versioning

`mentionpath.nvim` uses Git tags as its release version source of truth.

- Cut releases with SemVer tags such as `v0.1.0`.
- Track pending user-visible changes in [CHANGELOG.md](CHANGELOG.md).
- Push a `v*` tag to trigger GitHub Release creation.

Example `lazy.nvim` pin:

```lua
{
  "JuanCrg90/mentionpath.nvim",
  version = "v0.1.0",
}
```

### Local Development

Use `dir` when working from a local checkout:

```lua
return {
  {
    "mentionpath.nvim",
    dir = "/path/to/mentionpath.nvim",
    ft = "markdown",
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
    backend = "cmp",
  },
  root = {
    detector = nil,
  },
  files = {
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
  debug = {
    enabled = false,
    log_path = nil,
  },
})
```

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
- `mentionpath.token`: active `@query` extraction from cursor context.
- `mentionpath.matcher`: simple ranking against basenames and relative paths.
- `cmp_mentionpath`: `nvim-cmp` source adapter.

The cmp adapter is intentionally thin so Telescope or another backend can reuse the same root, file, token, and matcher modules later.

## Implementation Flow

1. `nvim-cmp` asks the source for completions after `@` or while typing.
2. The source exits unless the current buffer filetype is `markdown`.
3. `mentionpath.token` extracts the active no-space `@query` before the cursor.
4. `mentionpath.root` finds the project root.
5. `mentionpath.files` returns a cached file list or runs `fd` from the root.
6. `mentionpath.matcher` ranks relative paths.
7. The cmp item uses `textEdit` to replace only the active token with `@relative/path`.
8. Results are marked incomplete so cmp re-queries as the mention text changes.

## Notes

Install `fd` for the intended file discovery behavior:

```sh
brew install fd
```

Without `fd`, the plugin falls back to Git-tracked and untracked non-ignored files.
