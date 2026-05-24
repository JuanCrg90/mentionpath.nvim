-- Test token extraction for both triggers
local token = require("mentionpath.token")

-- Test file trigger (@)
local file_token = token.extract("Review @matcher", {
  file_trigger = "@",
  skill_trigger = "$",
})

assert(file_token, "expected file token to be extracted")
assert(file_token.kind == "file", "expected token kind to be file")
assert(file_token.query == "matcher", "expected query to be 'matcher'")
assert(file_token.token == "@matcher", "expected token to be '@matcher'")
assert(file_token.trigger == "@", "expected file trigger to be '@'")
assert(file_token.start_col == 8, "expected start_col at 8")
assert(file_token.end_col == 16, "expected end_col at 16")

-- Test skill trigger ($)
local skill_token = token.extract("Run $rails", {
  file_trigger = "@",
  skill_trigger = "$",
})

assert(skill_token, "expected skill token to be extracted")
assert(skill_token.kind == "skill", "expected token kind to be skill")
assert(skill_token.query == "rails", "expected query to be 'rails'")
assert(skill_token.token == "$rails", "expected token to be '$rails'")
assert(skill_token.trigger == "$", "expected skill trigger to be '$'")
assert(skill_token.start_col == 5, "expected start_col at 5")
assert(skill_token.end_col == 11, "expected end_col at 11")

assert(token.extract("Run $rails", {
  file_trigger = "@",
  skill_trigger = false,
}) == nil, "expected disabled skill trigger to return nil")

local custom_skill_token = token.extract("Run #rails", {
  file_trigger = "@",
  skill_trigger = "#",
})

assert(custom_skill_token, "expected custom skill token to be extracted")
assert(custom_skill_token.kind == "skill", "expected custom token kind to be skill")
assert(custom_skill_token.trigger == "#", "expected custom skill trigger to be '#'")
assert(custom_skill_token.token == "#rails", "expected custom token to be '#rails'")

-- Test no trigger returns nil
assert(token.extract("no trigger here", {
  file_trigger = "@",
  skill_trigger = "$",
}) == nil, "expected nil when no trigger present")

print("mentionpath token tests passed")

-- Test skill discovery
local skills = require("mentionpath.skills")
local test_skills_dir = vim.fn.tempname()

-- Create test skill directories
vim.fn.mkdir(test_skills_dir .. "/.agents/skills/rails-simplifier", "p")
vim.fn.writefile({"# Rails Simplifier"}, test_skills_dir .. "/.agents/skills/rails-simplifier/SKILL.md")
vim.fn.mkdir(test_skills_dir .. "/.agents/skills/gh-project-ticket-manager", "p")
vim.fn.writefile({"# GH Project Manager"}, test_skills_dir .. "/.agents/skills/gh-project-ticket-manager/SKILL.md")

-- Create a directory without SKILL.md (should not be discovered)
vim.fn.mkdir(test_skills_dir .. "/.agents/skills/incomplete-skill", "p")

-- Discover skills
local discovered_skills = {}
skills.list(test_skills_dir, { directory = ".agents/skills", marker_file = "SKILL.md" }, function(sk, _err)
  discovered_skills = sk
end)

-- Wait a tick for callback
vim.cmd.sleep("100m")

assert(#discovered_skills == 2, string.format("expected 2 skills, got %d: %s", #discovered_skills, vim.inspect(discovered_skills)))
assert(vim.tbl_contains(discovered_skills, "rails-simplifier"), "expected rails-simplifier skill")
assert(vim.tbl_contains(discovered_skills, "gh-project-ticket-manager"), "expected gh-project-ticket-manager skill")

-- Test skill_path helper
local full_path = skills.skill_path(test_skills_dir, "rails-simplifier", {
  directory = ".agents/skills",
  marker_file = "SKILL.md",
})
assert(full_path == ".agents/skills/rails-simplifier/SKILL.md", "expected skill path to be correct")

vim.fn.mkdir(test_skills_dir .. "/custom-skills/custom-skill", "p")
vim.fn.writefile({"# Custom Skill"}, test_skills_dir .. "/custom-skills/custom-skill/SKILL.md")

local custom_directory_skills = {}
skills.list(test_skills_dir, {
  directory = "custom-skills",
  marker_file = "SKILL.md",
}, function(sk, _err)
  custom_directory_skills = sk
end)

vim.cmd.sleep("100m")

assert(#custom_directory_skills == 1, "expected cache to account for custom skill directory")
assert(vim.tbl_contains(custom_directory_skills, "custom-skill"), "expected custom directory skill")

local config = require("mentionpath.config")
local source = require("mentionpath.source")

config.setup({
  root = {
    detector = function()
      return test_skills_dir
    end,
  },
  skills = {
    trigger = "#",
    directory = ".agents/skills",
    marker_file = "SKILL.md",
  },
})

local custom_completion = nil
source.complete({
  bufnr = vim.api.nvim_get_current_buf(),
  cursor = {
    row = 1,
  },
  cursor_before_line = "Run #rails",
}, function(result)
  custom_completion = result
end)

vim.cmd.sleep("100m")

assert(custom_completion, "expected custom trigger completion callback")
assert(custom_completion.items[1], "expected custom trigger completion item")
assert(custom_completion.items[1].textEdit.newText == "#rails-simplifier", "expected custom trigger in insert text")

config.setup({
  root = {
    detector = function()
      return test_skills_dir
    end,
  },
  skills = {
    enabled = false,
  },
})

local disabled_completion = nil
source.complete({
  bufnr = vim.api.nvim_get_current_buf(),
  cursor = {
    row = 1,
  },
  cursor_before_line = "Run $rails",
}, function(result)
  disabled_completion = result
end)

assert(disabled_completion, "expected disabled skill completion callback")
assert(#disabled_completion.items == 0, "expected disabled skill trigger to return no items")
assert(not disabled_completion.incomplete, "expected disabled skill trigger to stop completion")

config.setup()

print("mentionpath skills tests passed")
vim.cmd("qa")
