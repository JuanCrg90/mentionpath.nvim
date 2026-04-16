local M = {}

local separators = "[/_.%-]+"

local function basename(path)
  return path:match("([^/]+)$") or path
end

local function tokens(text)
  local result = {}

  for token in string.gmatch(text:lower(), "[^/_.%-]+") do
    table.insert(result, token)
  end

  return result
end

local function fuzzy_score(query, candidate)
  local score = 0
  local position = 1
  local last_match = 0

  for index = 1, #query do
    local char = query:sub(index, index)
    local found = candidate:find(char, position, true)

    if not found then
      return nil
    end

    score = score + 12

    if found == last_match + 1 then
      score = score + 8
    end

    score = score - (found - position)
    position = found + 1
    last_match = found
  end

  return score
end

local function token_prefix_score(query, path)
  local best = nil

  for _, token in ipairs(tokens(path)) do
    if token == query then
      best = math.max(best or 0, 620)
    elseif token:sub(1, #query) == query then
      best = math.max(best or 0, 560)
    elseif token:find(query, 1, true) then
      best = math.max(best or 0, 420)
    end
  end

  return best
end

local function score(query, path)
  local normalized_query = query:lower():gsub("^/+", "")

  if normalized_query == "" then
    return nil
  end

  local normalized_path = path:lower()
  local file = basename(normalized_path)
  local best = nil

  if file == normalized_query then
    best = 1000
  elseif file:sub(1, #normalized_query) == normalized_query then
    best = 760
  elseif file:find(normalized_query, 1, true) then
    best = 520
  end

  local token_score = token_prefix_score(normalized_query, normalized_path)

  if token_score then
    best = math.max(best or 0, token_score)
  end

  if normalized_path:find(normalized_query, 1, true) then
    best = math.max(best or 0, 360)
  end

  local fuzzy = fuzzy_score(normalized_query, normalized_path:gsub(separators, " "))

  if fuzzy then
    best = math.max(best or 0, 160 + fuzzy)
  end

  if not best then
    return nil
  end

  return best - (#path / 1000)
end

function M.match(query, files, opts)
  opts = opts or {}

  if query == "" then
    return {}
  end

  local matches = {}

  for _, path in ipairs(files) do
    local path_score = score(query, path)

    if path_score then
      table.insert(matches, {
        path = path,
        score = path_score,
      })
    end
  end

  table.sort(matches, function(left, right)
    if left.score == right.score then
      return left.path < right.path
    end

    return left.score > right.score
  end)

  local limit = opts.max_results or 50

  if #matches > limit then
    local limited = {}

    for index = 1, limit do
      limited[index] = matches[index]
    end

    return limited
  end

  return matches
end

M._score = score

return M
