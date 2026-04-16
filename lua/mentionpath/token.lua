local M = {}

local valid_chars = "[%w_%.%-%/]"

local function is_valid_char(char)
  return char:match(valid_chars) ~= nil
end

local function is_boundary(char)
  return char == "" or not is_valid_char(char)
end

function M.extract(cursor_before_line, opts)
  opts = opts or {}

  local trigger = opts.trigger or "@"
  local index = #cursor_before_line

  while index > 0 and is_valid_char(cursor_before_line:sub(index, index)) do
    index = index - 1
  end

  if cursor_before_line:sub(index, index) ~= trigger then
    return nil
  end

  if index > 1 and not is_boundary(cursor_before_line:sub(index - 1, index - 1)) then
    return nil
  end

  local query = cursor_before_line:sub(index + 1)

  return {
    start_col = index,
    end_col = #cursor_before_line + 1,
    query = query,
    token = trigger .. query,
  }
end

return M
