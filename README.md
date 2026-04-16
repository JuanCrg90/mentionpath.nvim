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
- Token-aware matching for basenames, path segments, underscores, hyphens, and fuzzy subsequences.

## Install

With lazy.nvim:

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
})
```

## Architecture

- `mentionpath.config`: user options and defaults.
- `mentionpath.root`: project root detection, using `git rev-parse --show-toplevel` first.
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

## Notes

Install `fd` for the intended file discovery behavior:

```sh
brew install fd
```

Without `fd`, the plugin falls back to Git-tracked and untracked non-ignored files.
