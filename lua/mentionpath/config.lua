local M = {}

local defaults = {
  trigger = "@",
  filetypes = { "markdown", "text" },
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
  skills = {
    enabled = true,
    trigger = "$",
    directory = ".agents/skills",
    marker_file = "SKILL.md",
    cache_ttl_ms = 5000,
  },
  matcher = {
    max_results = 50,
  },
  cmp = {
    source_name = "mentionpath",
    auto_register = true,
  },
  blink = {
    source_name = "mentionpath",
  },
  debug = {
    enabled = false,
    log_path = nil,
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
