vim.bo.filetype = "text"
local source = require("cmp_mentionpath").new()
assert(source:is_available(), "source should be available in text files")

vim.bo.filetype = "markdown"
assert(source:is_available(), "source should be available in Markdown")
assert(source:get_keyword_pattern():match("^@"), "keyword pattern should include the trigger")

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
