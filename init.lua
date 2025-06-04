require("custom.settings")
require("config.mini")

-- Keymaps that require plugins to have been set up. Might move these to /after at some point
vim.keymap.set('n', '<leader>mf', ':lua MiniFiles.open()<CR>', { desc = '[M]ini [F]iles' })
vim.keymap.set('n', '<leader>br', ':lua MiniBufremove.delete()<CR>', { desc = '[B]uffer [R]emove' })
