local mention_source = require("mentionpath.source")

local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

function source:get_debug_name()
  return "mentionpath"
end

function source:get_trigger_characters()
  return mention_source.trigger_characters()
end

function source:get_keyword_pattern()
  return mention_source.keyword_pattern()
end

function source:is_available()
  return mention_source.available()
end

function source:complete(params, callback)
  local context = params.context or {}

  mention_source.complete({
    bufnr = context.bufnr,
    cursor = context.cursor,
    cursor_before_line = context.cursor_before_line,
  }, function(result)
    callback({
      items = result.items,
      isIncomplete = result.incomplete,
    })
  end)
end

return source
