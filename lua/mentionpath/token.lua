local M = {}

local valid_chars = "[%w_%.%-%/]"

local function is_valid_char(char)
  return char:match(valid_chars) ~= nil
end

local function is_boundary(char)
  return char == "" or not is_valid_char(char)
end

function M.extract(cursor_before_line, triggers)
  triggers = triggers or {}

  local file_trigger = triggers.file_trigger
  if file_trigger == nil then
    file_trigger = triggers.trigger or "@"
  end

  local skill_trigger = triggers.skill_trigger
  if skill_trigger == nil and triggers.file_trigger == nil and triggers.trigger == nil then
    skill_trigger = "$"
  end

  if file_trigger then
    local file_token = M._extract_for_trigger(cursor_before_line, file_trigger)
    if file_token then
      file_token.kind = "file"
      return file_token
    end
  end

  if skill_trigger then
    local skill_token = M._extract_for_trigger(cursor_before_line, skill_trigger)
    if skill_token then
      skill_token.kind = "skill"
      return skill_token
    end
  end

  return nil
end

function M._extract_for_trigger(cursor_before_line, trigger)
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
    trigger = trigger,
    token = trigger .. query,
  }
end

return M
