local matcher = require("mentionpath.matcher")
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

print("mentionpath minimal tests passed")
