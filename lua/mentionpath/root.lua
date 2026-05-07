local M = {}

local cache = {}
local uv = vim.uv or vim.loop

local function dirname(path)
  return vim.fn.fnamemodify(path, ":h")
end

local function realpath(path)
  local resolved = uv.fs_realpath(path)
  return resolved or path
end

local function buffer_dir(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)

  if name == "" then
    return uv.cwd()
  end

  return dirname(name)
end

local function current_cwd()
  return realpath(vim.fn.getcwd())
end

local function git_root(dir)
  local key = realpath(dir)

  if cache[key] ~= nil then
    return cache[key]
  end

  local result = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })

  if vim.v.shell_error == 0 and result[1] and result[1] ~= "" then
    cache[key] = realpath(result[1])
    return cache[key]
  end

  cache[key] = false
  return nil
end

local function find_marker_root(dir)
  local current = realpath(dir)

  while current and current ~= "" do
    if uv.fs_stat(current .. "/.git") then
      return current
    end

    local parent = dirname(current)

    if parent == current then
      break
    end

    current = parent
  end

  return nil
end

function M.detect(bufnr, opts)
  opts = opts or {}

  if type(opts.detector) == "function" then
    local root = opts.detector(bufnr)

    if root and root ~= "" then
      return realpath(root)
    end
  end

  local dir = buffer_dir(bufnr or 0)
  local detected = git_root(dir) or find_marker_root(dir)

  if detected then
    return detected
  end

  local cwd = current_cwd()

  if cwd ~= realpath(dir) then
    detected = git_root(cwd) or find_marker_root(cwd)

    if detected then
      return detected
    end
  end

  return realpath(dir)
end

function M.clear_cache()
  cache = {}
end

return M
