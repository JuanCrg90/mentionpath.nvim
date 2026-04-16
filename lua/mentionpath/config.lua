local M = {}

local defaults = {
  trigger = "@",
  filetypes = { "markdown" },
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
    command = nil,
    fd_args = {
      "--type",
      "f",
      "--strip-cwd-prefix",
      "--color",
      "never",
      ".",
    },
  },
  matcher = {
    max_results = 50,
  },
  cmp = {
    source_name = "mentionpath",
    auto_register = true,
  },
}

local options = vim.deepcopy(defaults)

local function merge(base, override)
  return vim.tbl_deep_extend("force", base, override or {})
end

function M.setup(opts)
  options = merge(vim.deepcopy(defaults), opts)
end

function M.get()
  return options
end

function M.filetype_enabled(filetype)
  for _, enabled in ipairs(options.filetypes) do
    if enabled == filetype then
      return true
    end
  end

  return false
end

return M
