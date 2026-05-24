local M = {}

local cache = {}
local uv = vim.uv or vim.loop

local function now()
  return uv.hrtime() / 1000000
end

local function skills_directory(root, opts)
  opts = opts or {}
  local dir = opts.directory or ".agents/skills"
  return root .. "/" .. dir
end

local function skill_marker_path(skill_dir, opts)
  opts = opts or {}
  local marker = opts.marker_file or "SKILL.md"
  return skill_dir .. "/" .. marker
end

local function cache_key(root, opts)
  opts = opts or {}
  local dir = opts.directory or ".agents/skills"
  local marker = opts.marker_file or "SKILL.md"
  return table.concat({ root, dir, marker }, "\0")
end

-- Discover skills by checking for marker files in subdirectories
local function discover_skills(root, opts)
  opts = opts or {}
  local skill_names = {}
  local marker = opts.marker_file or "SKILL.md"

  local skills_dir = skills_directory(root, opts)

  -- Check if skills directory exists
  if not vim.fn.isdirectory(skills_dir) then
    return skill_names
  end

  -- Get all immediate children
  local all_entries = vim.fn.globpath(skills_dir, "*", 0, 1, 1)

  for _, entry in ipairs(all_entries) do
    local name = vim.fn.fnamemodify(entry, ":t")

    -- Skip hidden directories
    if name:sub(1, 1) == "." then
      goto continue
    end

    -- Only process directories
    if vim.fn.isdirectory(entry) == 1 then
      -- Check if marker file exists
      local marker_path = entry .. "/" .. marker
      if vim.fn.filereadable(marker_path) == 1 then
        table.insert(skill_names, name)
      end
    end

    ::continue::
  end

  return skill_names
end

function M.list(root, opts, callback)
  opts = opts or {}

  local key = cache_key(root, opts)
  local entry = cache[key]
  local ttl = opts.cache_ttl_ms or 0

  if entry and now() - entry.created_at < ttl then
    callback(entry.skills, nil)
    return
  end

  -- Discover skills synchronously and schedule callback
  vim.schedule(function()
    local skills = discover_skills(root, opts)

    cache[key] = {
      created_at = now(),
      skills = skills,
    }

    callback(skills, nil)
  end)
end

function M.clear_cache(root)
  if root then
    cache[root] = nil
    return
  end

  cache = {}
end

-- Return the full path for a skill (for display purposes)
function M.skill_path(root, skill_name, opts)
  opts = opts or {}
  local dir = opts.directory or ".agents/skills"
  local marker = opts.marker_file or "SKILL.md"
  return string.format("%s/%s/%s", dir, skill_name, marker)
end

return M
