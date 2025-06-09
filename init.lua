vim.opt.runtimepath:append("~/.config/nvim-lsp")
require("custom.settings")
require("config.mini")

-- Keymaps that require plugins to have been set up. Might move these to /after at some point
vim.keymap.set('n', '<leader>mf', ':lua MiniFiles.open(vim.api.nvim_buf_get_name(0), false)<CR>', { desc = '[M]ini [F]iles' })
vim.keymap.set('n', '<leader>br', ':lua MiniBufremove.delete()<CR>', { desc = '[B]uffer [R]emove' })
