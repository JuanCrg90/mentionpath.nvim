local ok, mentionpath = pcall(require, "mentionpath")

if ok then
  mentionpath.register_cmp_source()
end
