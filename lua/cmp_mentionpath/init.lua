local config = require("mentionpath.config")
local files = require("mentionpath.files")
local matcher = require("mentionpath.matcher")
local root = require("mentionpath.root")
local token = require("mentionpath.token")

local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

function source:get_debug_name()
  return "mentionpath"
end

function source:get_trigger_characters()
  return { config.get().trigger }
end

function source:is_available()
  return config.filetype_enabled(vim.bo.filetype)
end

local function cursor_line(cursor)
  if cursor and cursor.row then
    return cursor.row - 1
  end

  if cursor and cursor.line then
    return cursor.line
  end

  return vim.api.nvim_win_get_cursor(0)[1] - 1
end

local function completion_item(path, item_index, active_token, line)
  local inserted = "@" .. path

  return {
    label = path,
    insertText = inserted,
    filterText = active_token.query,
    sortText = string.format("%04d", item_index),
    kind = 17,
    textEdit = {
      newText = inserted,
      range = {
        start = {
          line = line,
          character = active_token.start_col - 1,
        },
        ["end"] = {
          line = line,
          character = active_token.end_col - 1,
        },
      },
    },
  }
end

function source:complete(params, callback)
  local options = config.get()
  local context = params.context or {}
  local cursor_before_line = context.cursor_before_line or ""
  local active_token = token.extract(cursor_before_line, options)

  if not active_token or #active_token.query < options.min_chars then
    callback({ items = {}, isIncomplete = false })
    return
  end

  local bufnr = context.bufnr or vim.api.nvim_get_current_buf()
  local project_root = root.detect(bufnr, options.root)

  files.list(project_root, options.files, function(paths)
    local matches = matcher.match(active_token.query, paths, {
      max_results = options.max_results or options.matcher.max_results,
    })
    local items = {}
    local line = cursor_line(context.cursor)

    for index, match in ipairs(matches) do
      table.insert(items, completion_item(match.path, index, active_token, line))
    end

    callback({
      items = items,
      isIncomplete = false,
    })
  end)
end

return source
