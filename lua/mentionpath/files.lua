local M = {}

local cache = {}
local uv = vim.uv or vim.loop

local function now()
  return uv.hrtime() / 1000000
end

local function split_lines(output)
  local lines = {}

  for line in string.gmatch(output or "", "[^\r\n]+") do
    if line ~= "" then
      table.insert(lines, line)
    end
  end

  return lines
end

local function executable(name)
  return vim.fn.executable(name) == 1
end

local function fd_command(opts)
  local command = opts.command

  if command then
    return command
  end

  if executable("fd") then
    return "fd"
  end

  if executable("fdfind") then
    return "fdfind"
  end

  return nil
end

local function build_command(opts)
  local command = fd_command(opts)

  if command then
    local argv = { command }

    vim.list_extend(argv, opts.fd_args or {})

    return argv
  end

  return { "git", "ls-files", "--cached", "--others", "--exclude-standard" }
end

local function run(argv, cwd, callback)
  if vim.system then
    vim.system(argv, { cwd = cwd, text = true }, function(result)
      vim.schedule(function()
        callback(result.code, split_lines(result.stdout), result.stderr)
      end)
    end)

    return
  end

  local stdout = {}
  local stderr = {}

  vim.fn.jobstart(argv, {
    cwd = cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      vim.list_extend(stdout, data or {})
    end,
    on_stderr = function(_, data)
      vim.list_extend(stderr, data or {})
    end,
    on_exit = function(_, code)
      callback(code, vim.tbl_filter(function(line)
        return line ~= ""
      end, stdout), table.concat(stderr, "\n"))
    end,
  })
end

function M.list(root, opts, callback)
  opts = opts or {}

  local entry = cache[root]
  local ttl = opts.cache_ttl_ms or 0

  if entry and now() - entry.created_at < ttl then
    callback(entry.files, nil)
    return
  end

  local argv = build_command(opts)

  run(argv, root, function(code, files, stderr)
    if code ~= 0 then
      callback({}, stderr or "mentionpath: file collection failed")
      return
    end

    cache[root] = {
      created_at = now(),
      files = files,
    }

    callback(files, nil)
  end)
end

function M.clear_cache(root)
  if root then
    cache[root] = nil
    return
  end

  cache = {}
end

M._split_lines = split_lines
M._build_command = build_command

return M
