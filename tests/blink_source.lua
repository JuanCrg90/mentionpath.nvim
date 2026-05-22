vim.bo.filetype = "markdown"

local source = require("mentionpath.blink").new()

assert(source:enabled(), "source should be available in Markdown")
assert(vim.deep_equal(source:get_trigger_characters(), { "@" }), "expected @ trigger")

source:get_completions({
  bufnr = vim.api.nvim_get_current_buf(),
  cursor = {
    row = 1,
    col = 15,
  },
  line = "Review @matcher",
}, function(result)
  local first = result.items[1]

  assert(first, "expected at least one completion item")
  assert(first.textEdit.newText == "@lua/mentionpath/matcher.lua", "expected matcher module insert text")
  assert(first.filterText == "@lua/mentionpath/matcher.lua", "expected filter text to use candidate path")
  assert(first.textEdit.range.start.character == 7, "expected replacement to start at @")
  assert(first.textEdit.range["end"].character == 15, "expected replacement to end at cursor")
  assert(result.is_incomplete_forward, "expected source to re-query as the mention changes")
  assert(not result.is_incomplete_backward, "expected backward completion to stay complete")

  print("mentionpath blink source test passed")
  vim.cmd("qa")
end)
