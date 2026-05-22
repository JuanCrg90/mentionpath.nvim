local config = require("mentionpath.config")
local log = require("mentionpath.log")

local M = {}

local function create_commands()
  vim.api.nvim_create_user_command("MentionpathLog", function()
    vim.cmd.edit(log.path())
  end, { desc = "Open mentionpath.nvim debug log" })

  vim.api.nvim_create_user_command("MentionpathClearLog", function()
    log.clear()
    vim.notify("mentionpath.nvim log cleared: " .. log.path())
  end, { desc = "Clear mentionpath.nvim debug log" })
end

function M.setup(opts)
  config.setup(opts)
  create_commands()

  local options = config.get()
  log.write("setup", options)

  if options.ui.backend ~= "blink" and options.cmp.auto_register then
    M.register_cmp_source()
  end
end

function M.blink_provider()
  local options = config.get()

  return {
    name = options.blink.source_name,
    module = "mentionpath.blink",
  }
end

function M.register_cmp_source()
  if vim.g.mentionpath_cmp_registered then
    return
  end

  local ok_cmp, cmp = pcall(require, "cmp")

  if not ok_cmp then
    log.write("register_cmp_source skipped", "cmp unavailable")
    return
  end

  local ok_source, source = pcall(require, "cmp_mentionpath")

  if not ok_source then
    log.write("register_cmp_source skipped", "cmp_mentionpath unavailable")
    return
  end

  local options = config.get()

  if options.ui.backend == "blink" then
    log.write("register_cmp_source skipped", "blink backend configured")
    return
  end

  cmp.register_source(options.cmp.source_name, source.new())
  vim.g.mentionpath_cmp_registered = true
  log.write("register_cmp_source", "registered")
end

function M.clear_cache()
  require("mentionpath.files").clear_cache()
  require("mentionpath.root").clear_cache()
  log.write("clear_cache")
end

return M
