return {
  'echasnovski/mini.nvim',
  version = false,
  config = function()
    require('mini.icons').setup({style = 'glyph'})
    require('mini.statusline').setup({use_icons = true})
    require('mini.notify').setup()
    require('mini.git').setup()
    require('mini.diff').setup({
      view = {
	style = 'sign',
	-- Signs used for hunks with 'sign' view
	signs = { add = '▒', change = '▒', delete = '▒' },

	-- Priority of used visualization extmarks
	priority = 199,
      }
    })
    require('mini.cursorword').setup()

    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

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
	miniclue.gen_clues.builtin_completion(),
	miniclue.gen_clues.g(),
	miniclue.gen_clues.marks(),
	miniclue.gen_clues.registers(),
	miniclue.gen_clues.windows(),
	miniclue.gen_clues.z(),
      },
    })
    require('mini.completion').setup()
    local gen_loader = require('mini.snippets').gen_loader
    require('mini.snippets').setup({
      snippets = {
	gen_loader.from_lang(),
      }
    })
  end,
}

