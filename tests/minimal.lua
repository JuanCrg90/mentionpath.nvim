local matcher = require("mentionpath.matcher")
local root = require("mentionpath.root")
local token = require("mentionpath.token")

local function assert_equal(expected, actual)
  if expected ~= actual then
    error(string.format("expected %s, got %s", vim.inspect(expected), vim.inspect(actual)))
  end
end

local function assert_truthy(value, message)
  if not value then
    error(message or "expected truthy value")
  end
end

local extracted = token.extract("Please review @controller", { trigger = "@" })
assert_truthy(extracted)
assert_equal("controller", extracted.query)
assert_equal(15, extracted.start_col)
assert_equal(26, extracted.end_col)

assert_equal(nil, token.extract("email@example", { trigger = "@" }))
assert_equal(nil, token.extract("no mention here", { trigger = "@" }))

local matches = matcher.match("controller", {
  "app/models/order.rb",
  "app/controllers/orders_controller.rb",
  "app/controllers/users_controller.rb",
  "README.md",
}, { max_results = 10 })

assert_equal("app/controllers/users_controller.rb", matches[1].path)
assert_equal("app/controllers/orders_controller.rb", matches[2].path)

local order_matches = matcher.match("order", {
  "app/services/order_service.rb",
  "app/models/order.rb",
  "app/controllers/orders_controller.rb",
}, { max_results = 10 })

assert_equal("app/models/order.rb", order_matches[1].path)

local controller_matches = matcher.match("contact_controller", {
  "app/controllers/contact_controller.rb",
}, { max_results = 10 })

assert_equal("app/controllers/contact_controller.rb", controller_matches[1].path)

local case_matches = matcher.match("Contact_Controller", {
  "app/controllers/contact_controller.rb",
}, { max_results = 10 })

assert_equal("app/controllers/contact_controller.rb", case_matches[1].path)

local slash_matches = matcher.match("/lua/", {
  "lua/mentionpath/init.lua",
}, { max_results = 10 })

assert_equal("lua/mentionpath/init.lua", slash_matches[1].path)

root.clear_cache()

vim.o.swapfile = false
vim.cmd.enew()

local tmp_bufnr = vim.api.nvim_get_current_buf()
local tmp_path = vim.fn.tempname() .. ".md"

vim.fn.mkdir(vim.fn.fnamemodify(tmp_path, ":h"), "p")
vim.api.nvim_buf_set_name(tmp_bufnr, tmp_path)

local expected_root = (vim.uv or vim.loop).fs_realpath(vim.fn.getcwd()) or vim.fn.getcwd()

assert_equal(expected_root, root.detect(tmp_bufnr, {}))

print("mentionpath minimal tests passed")
