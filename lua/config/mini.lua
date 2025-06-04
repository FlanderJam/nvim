-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = { 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.nvim', mini_path }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = path_package } })

-- Use 'mini.deps'. `now()` and `later()` are helpers for a safe two-stage
-- startup and are optional.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later


-------------------------------------------------------------------------------
-- Mini Now Functions
-------------------------------------------------------------------------------
now(function()
  require('mini.notify').setup()
  vim.notify = require('mini.notify').make_notify()
end)
now(function() require('mini.icons').setup({style = 'glyph'}) end)
now(function() require('mini.statusline').setup({use_icons = true}) end)
now(function() require('mini.files').setup() end)
now(function() require('mini.bufremove').setup() end)


-------------------------------------------------------------------------------
-- Mini Later Functions
-------------------------------------------------------------------------------
later(function() require('mini.comment').setup() end)

later(function() require('mini.pick').setup() end)
later(function()
  require('mini.extra').setup()
  vim.keymap.set('n', '<leader>sh', MiniPick.builtin.help, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', MiniExtra.pickers.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', MiniPick.builtin.files, { desc = '[S]earch [F]iles' })
  -- vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set('n', '<leader>sw', MiniPick.builtin.grep, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', MiniPick.builtin.grep_live, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', MiniExtra.pickers.diagnostic, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', MiniPick.builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', MiniExtra.pickers.visit_paths, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader><leader>', MiniPick.builtin.buffers, { desc = '[ ] Find existing buffers' })

  vim.keymap.set('n', '<leader>/', function() MiniExtra.pickers.buf_lines({ scope = 'current' }) end, { desc = '[/] Fuzzily search in current buffer' })
  vim.keymap.set('n', '<leader>s/', function() MiniExtra.pickers.buf_lines({ scope = 'all'  }) end, { desc = '[S]earch [/] in Open Files' })

  vim.keymap.set('n', '<leader>sn', function() MiniPick.builtin.files({ source = { items = vim.fn.stdpath('config') } }) end, { desc = '[S]earch [/] in Open Files' })
end)

-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yinq - [Y]ank [I]nside [N]ext [']quote
--  - ci'  - [C]hange [I]nside [']quote
later(function() require('mini.ai').setup({ n_lines = 500 }) end)

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
later(function() require('mini.surround').setup() end)

later(function() require('mini.git').setup() end)
later(function()
  require('mini.diff').setup({
  view = {
    style = 'sign',
    -- Signs used for hunks with 'sign' view
    signs = { add = '▒', change = '▒', delete = '▒' },

    -- Priority of used visualization extmarks
    priority = 199,
  }
})
end)
later(function() require('mini.cursorword').setup() end)


later(function()
  local miniclue = require('mini.clue')
  miniclue.setup({
    triggers = {
      -- Leader triggers
      { mode = 'n', keys = '<Leader>' },
      { mode = 'x', keys = '<Leader>' },

      -- Built-in completion
      { mode = 'i', keys = '<C-x>' },

      -- `g` key
      { mode = 'n', keys = 'g' },
      { mode = 'x', keys = 'g' },

      -- Marks
      { mode = 'n', keys = "'" },
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },

      -- Registers
      { mode = 'n', keys = '"' },
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },

      -- Window commands
      { mode = 'n', keys = '<C-w>' },

      -- `z` key
      { mode = 'n', keys = 'z' },
      { mode = 'x', keys = 'z' },
    },

    window = {
      delay = 0,
    },

    clues = {
      -- Enhance this by adding descriptions for <Leader> mapping groups
      { mode = 'n', keys = '<leader>c', desc = '[C]ode' },
      -- { '<leader>c_', hidden = true },
      { mode = 'n', keys = '<leader>d', desc = '[D]ocument' },
      -- { '<leader>d_', hidden = true },
      { mode = 'n', keys = '<leader>r', desc = '[R]ename' },
      -- { '<leader>r_', hidden = true },
      { mode = 'n', keys = '<leader>s', desc = '[S]earch' },
      -- { '<leader>s_', hidden = true },
      { mode = 'n', keys = '<leader>w', desc = '[W]orkspace' },
      -- { '<leader>w_', hidden = true },
      { mode = 'n', keys = '<leader>s', desc = '[S]earch' },
      { mode = 'n', keys = '<leader>m', desc = '[M]ini' },
      { mode = 'n', keys = '<leader>b', desc = '[B]uffer' },
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
    },
  })
end)
later(function()
  local gen_loader = require('mini.snippets').gen_loader
  require('mini.snippets').setup({
    snippets = {
      gen_loader.from_lang(),
    }
  })
end)
later(function()
  require('mini.completion').setup({
    -- This adds a massive delay to autocompletion appearing. This is to rely less on the LSP and more on my brain
    -- In order to open completions manually, just pres <C-Space>
    delay = { completion = 100000000000, info = 100, signature = 50 },    })
end)

later(function()
  local hipatterns = require('mini.hipatterns')
  hipatterns.setup({
    highlighters = {
      -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
      fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
      hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
      todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
      note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

      -- Highlight hex color strings (`#rrggbb`) using that color
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

-------------------------------------------------------------------------------
-- External Package Now Functions
-------------------------------------------------------------------------------
now(function()
  require('config.plugins.theme')(add)
end)
now(function()
  require('config.plugins.lsp')(add)
end)

-------------------------------------------------------------------------------
-- External Package Later Functions
-------------------------------------------------------------------------------
later(function()
  require('config.plugins.treesitter')(add)
end)
later(function()
  require('config.plugins.lazydev')(add)
end)
