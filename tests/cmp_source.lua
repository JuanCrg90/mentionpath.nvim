vim.bo.filetype = "text"
local source = require("cmp_mentionpath").new()
assert(source:is_available(), "source should be available in text files")

vim.bo.filetype = "markdown"
assert(source:is_available(), "source should be available in Markdown")
local pattern = source:get_keyword_pattern()
assert(pattern:find("@", 1, true), "keyword pattern should include @ trigger")

local config = require("mentionpath.config")
local mention_source = require("mentionpath.source")

config.setup({ skills = { enabled = false } })
local disabled_triggers = mention_source.trigger_characters()
assert(vim.tbl_contains(disabled_triggers, "@"), "expected @ trigger when files are enabled")
assert(not vim.tbl_contains(disabled_triggers, "$"), "expected disabled skill trigger to be omitted")
assert(not mention_source.keyword_pattern():find("$", 1, true), "keyword pattern should omit disabled skill trigger")

config.setup({ trigger = "!", skills = { trigger = "#" } })
local custom_triggers = mention_source.trigger_characters()
assert(vim.tbl_contains(custom_triggers, "!"), "expected custom file trigger")
assert(vim.tbl_contains(custom_triggers, "#"), "expected custom skill trigger")
assert(mention_source.keyword_pattern():find("!", 1, true), "keyword pattern should include custom file trigger")
assert(mention_source.keyword_pattern():find("#", 1, true), "keyword pattern should include custom skill trigger")

config.setup()

source:complete({
  context = {
    bufnr = vim.api.nvim_get_current_buf(),
    cursor = {
      row = 1,
    },
    cursor_before_line = "@",
  },
}, function(result)
  assert(#result.items == 0, "expected no items for bare trigger")
  assert(result.isIncomplete, "expected bare trigger to keep source active")
end)

source:complete({
  context = {
    bufnr = vim.api.nvim_get_current_buf(),
    cursor = {
      row = 1,
    },
    cursor_before_line = "Review @matcher",
  },
}, function(result)
  local first = result.items[1]

  assert(first, "expected at least one completion item")
  assert(first.textEdit.newText == "@lua/mentionpath/matcher.lua", "expected matcher module insert text")
  assert(first.filterText == "@lua/mentionpath/matcher.lua", "expected filter text to use candidate path")
  assert(first.textEdit.range.start.character == 7, "expected replacement to start at @")
  assert(first.textEdit.range["end"].character == 15, "expected replacement to end at cursor")
  assert(result.isIncomplete, "expected source to re-query as the mention changes")

  print("mentionpath cmp source test passed")
  vim.cmd("qa")
end)
