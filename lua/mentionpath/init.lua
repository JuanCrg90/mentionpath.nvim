local config = require("mentionpath.config")

local M = {}

function M.setup(opts)
  config.setup(opts)

  local options = config.get()

  if options.cmp.auto_register then
    M.register_cmp_source()
  end
end

function M.register_cmp_source()
  if vim.g.mentionpath_cmp_registered then
    return
  end

  local ok_cmp, cmp = pcall(require, "cmp")

  if not ok_cmp then
    return
  end

  local ok_source, source = pcall(require, "cmp_mentionpath")

  if not ok_source then
    return
  end

  cmp.register_source(config.get().cmp.source_name, source.new())
  vim.g.mentionpath_cmp_registered = true
end

function M.clear_cache()
  require("mentionpath.files").clear_cache()
  require("mentionpath.root").clear_cache()
end

return M
