local mention_source = require("mentionpath.source")

local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

function source:enabled()
  return mention_source.available()
end

function source:get_trigger_characters()
  return mention_source.trigger_characters()
end

local function cursor_before_line(context)
  if context.cursor_before_line then
    return context.cursor_before_line
  end

  if not context.line then
    return ""
  end

  local cursor = context.cursor or {}
  local column = cursor.character or cursor.col or cursor[2]

  if not column then
    return context.line
  end

  return context.line:sub(1, column)
end

function source:get_completions(context, callback)
  mention_source.complete({
    bufnr = context.bufnr,
    cursor = context.cursor,
    cursor_before_line = cursor_before_line(context),
  }, function(result)
    callback({
      items = result.items,
      is_incomplete_backward = false,
      is_incomplete_forward = result.incomplete,
    })
  end)
end

return source
