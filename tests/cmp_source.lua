vim.bo.filetype = "markdown"

local source = require("cmp_mentionpath").new()

assert(source:is_available(), "source should be available in Markdown")

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
  assert(first.textEdit.range.start.character == 7, "expected replacement to start at @")
  assert(first.textEdit.range["end"].character == 15, "expected replacement to end at cursor")

  print("mentionpath cmp source test passed")
  vim.cmd("qa")
end)
