return function(add)
  add({
    source = "nvim-treesitter/nvim-treesitter",
    -- Use 'master' while monitoring updates in 'main'
    checkout = "main",
    monitor = "main",
    -- Perform action after every checkout
    hooks = {
      post_checkout = function()
        vim.cmd("TSUpdate")
      end,
    },
  })
  -- Possible to immediately execute code which depends on the added plugin
  local treesitter = require("nvim-treesitter")
  treesitter.install({ "nu", "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" })
end
