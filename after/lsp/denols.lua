return {
  root_dir = function(bufnr, on_dir)
    -- activate for deno projects
    local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
    if deno_root then
      on_dir(deno_root)
      return
    end
    -- also activate for lone TS/JS files with no package.json ancestor
    local npm_root = vim.fs.root(bufnr, { "package.json" })
    if not npm_root then
      -- use the file's own directory as root
      on_dir(vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
    end
  end,
}
