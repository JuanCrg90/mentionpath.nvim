local config = require("mentionpath.config")

local M = {}

local function path()
	return config.get().debug.log_path or (vim.fn.stdpath("state") .. "/mentionpath.log")
end

local function ensure_parent(log_path)
	vim.fn.mkdir(vim.fn.fnamemodify(log_path, ":h"), "p")
end

local function serialize(value)
	if value == nil then
		return ""
	end

	if type(value) == "string" then
		return value:gsub("\n", " ")
	end

	return vim.inspect(value):gsub("\n", " ")
end

function M.path()
	return path()
end

function M.enabled()
	return config.get().debug.enabled
end

function M.write(event, data)
	if not M.enabled() then
		return
	end

	local log_path = path()
	ensure_parent(log_path)

	local line = string.format("%s %s %s", os.date("%Y-%m-%d %H:%M:%S"), event, serialize(data))

	vim.fn.writefile({ line }, log_path, "a")
end

function M.clear()
	local log_path = path()
	ensure_parent(log_path)
	vim.fn.writefile({}, log_path)
end

return M
