-- catppuccin
-- return function(add)
--   add({
--     source = "catppuccin/nvim",
--     name = "catppuccin"
--   })
--   vim.o.termguicolors = true
--   vim.cmd('colorscheme catppuccin-mocha')
-- end

-- ember
return function(add)
  add({
    source = "ember-theme/nvim",
    name = "ember",
  })
  vim.o.termguicolors = true
  vim.cmd("colorscheme ember")
end
