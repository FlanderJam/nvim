return {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { "package.json" })
    if root then
      on_dir(root)
    end
    -- no call to on_dir = don't activate
  end,
}
