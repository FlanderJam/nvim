return function(add)
  add({
    source = "catppuccin/nvim",
    name = "catppuccin"
  })
  vim.o.termguicolors = true
  vim.cmd('colorscheme catppuccin-mocha')
end
