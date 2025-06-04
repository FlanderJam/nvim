return function(add)
  -- Use other plugins with `add()`. It ensures plugin is available in current
  -- session (installs if absent)
  add({
    source = 'mason-org/mason-lspconfig.nvim',
    -- Supply dependencies near target plugin
    depends = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig', },
  })

  -- Brief Aside: **What is LSP?**
  --
  -- LSP is an acronym you've probably heard, but might not understand what it is.
  --
  -- LSP stands for Language Server Protocol. It's a protocol that helps editors
  -- and language tooling communicate in a standardized fashion.
  --
  -- In general, you have a "server" which is some tool built to understand a particular
  -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc). These Language Servers
  -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
  -- processes that communicate with some "client" - in this case, Neovim!
  --
  -- LSP provides Neovim with features like:
  --  - Go to definition
  --  - Find references
  --  - Autocompletion
  --  - Symbol Search
  --  - and more!
  --
  -- Thus, Language Servers are external tools that must be installed separately from
  -- Neovim. This is where `mason` and related plugins come into play.
  --
  -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
  -- and elegantly composed help section, `:help lsp-vs-treesitter`

  --  This function gets run when an LSP attaches to a particular buffer.
  --    That is to say, every time a new file is opened that is associated with
  --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
  --    function will be executed to configure the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      -- NOTE: Remember that lua is a real programming language, and as such it is possible
      -- to define small helper and utility functions so you don't have to repeat yourself
      -- many times.
      --
      -- In this case, we create a function that lets us more easily define mappings specific
      -- for LSP related items. It sets the mode, buffer and description for us each time.
      local map = function(keys, func, desc)
	vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Jump to the definition of the word under your cursor.
      --  This is where a variable was first declared, or where a function is defined, etc.
      --  To jump back, press <C-T>.
      map('gd', function() MiniExtra.pickers.lsp({ scope = "definition" }) end, '[G]oto [D]efinition')

      -- Find references for the word under your cursor.
      map('gr', function() MiniExtra.pickers.lsp({ scope = "references" }) end, '[G]oto [R]eferences')

      -- Jump to the implementation of the word under your cursor.
      --  Useful when your language has ways of declaring types without an actual implementation.
      map('gI', function() MiniExtra.pickers.lsp({ scope = "implementation" }) end, '[G]oto [I]mplementation')

      -- Jump to the type of the word under your cursor.
      --  Useful when you're not sure what type a variable is and you want to see
      --  the definition of its *type*, not where it was *defined*.
      map('<leader>D', function() MiniExtra.pickers.lsp({ scope = "type_definition" }) end, 'Type [D]efinition')

      -- Fuzzy find all the symbols in your current document.
      --  Symbols are things like variables, functions, types, etc.
      map('<leader>ds', function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end, '[D]ocument [S]ymbols')

      -- Fuzzy find all the symbols in your current workspace
      --  Similar to document symbols, except searches over your whole project.
      map('<leader>ws', function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end, '[W]orkspace [S]ymbols')

      -- Rename the variable under your cursor
      --  Most Language Servers support renaming across files, etc.
      map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

      -- Opens a popup that displays documentation about the word under your cursor
      --  See `:help K` for why this keymap
      map('K', vim.lsp.buf.hover, 'Hover Documentation')

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      --  For example, in C this would take you to the header
      map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      --    See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client.server_capabilities.documentHighlightProvider then
	vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
	  buffer = event.buf,
	  callback = vim.lsp.buf.document_highlight,
	})

	vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
	  buffer = event.buf,
	  callback = vim.lsp.buf.clear_references,
	})
      end
    end,
  })

  -- LSP servers and clients are able to communicate to each other what features they support.
  --  By default, Neovim doesn't support everything that is in the LSP Specification.
  --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
  --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --
  --  Add any additional override configuration in the following tables. Available keys are:
  --  - cmd (table): Override the default command used to start the server
  --  - filetypes (table): Override the default list of associated filetypes for the server
  --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
  --  - settings (table): Override the default settings passed when initializing the server.
  --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
  local nvim_lsp = require 'lspconfig'
  local servers = {
    -- clangd = {},
    gopls = {},
    html = {},
    cssls = {},
    -- pyright = {},
    rust_analyzer = {},
    ts_ls = {
      root_dir = function(bufnr, on_dir)
	local match = nvim_lsp.util.root_pattern('package.json')(bufnr)
	local deno_match = nvim_lsp.util.root_pattern('deno.json', 'deno.jsonc', 'deno.lock')(bufnr)
	if match ~= nil and deno_match == nil then
	  on_dir(match)
	end
      end,
      single_file_support = false,
      settings = {},
    },
    emmet_language_server = {},
    denols = {
      root_dir = function(bufnr, on_dir)
	local match = nvim_lsp.util.root_pattern('deno.json', 'deno.jsonc', 'deno.lock')(bufnr)
	if match ~= nil then
	  on_dir(match)
	end
      end,
      settings = {},
    },

    lua_ls = {},
    svelte = {},
    tailwindcss = {},

    zls = {
      -- Server-specific settings. See `:help lspconfig-setup`

      -- omit the following line if `zls` is in your PATH
      cmd = { '/opt/zig/zls/zls' },
      -- There are two ways to set config options:
      --   - edit your `zls.json` that applies to any editor that uses ZLS
      --   - set in-editor config options with the `settings` field below.
      --
      -- Further information on how to configure ZLS:
      -- https://zigtools.org/zls/configure/
      settings = {
	zls = {
	  -- Whether to enable build-on-save diagnostics
	  --
	  -- Further information about build-on save:
	  -- https://zigtools.org/zls/guides/build-on-save/
	  -- enable_build_on_save = true,

	  -- Neovim already provides basic syntax highlighting
	  semantic_tokens = "partial",

	  -- omit the following line if `zig` is in your PATH
	  -- zig_exe_path = '/path/to/zig_executable'
	}
      }
    },
  }

  for key, value in pairs(servers) do
    vim.lsp.config(key, value)
  end


  require('lspconfig').nushell.setup({
    cmd = { "nu", "--lsp" },
    filetypes = { "nu" },
    -- root_dir = require("lspconfig.util").find_git_ancestor,
    single_file_support = true,
  })


  -- Ensure the servers and tools above are installed
  --  To check the current status of installed tools and/or manually install
  --  other tools, you can run
  --    :Mason
  --
  --  You can press `g?` for help in this menu
  require('mason').setup()

  -- You can add other tools here that you want Mason to install
  -- for you, so that they are available from within Neovim.
  local ensure_installed = vim.tbl_keys(servers or {})
  -- TODO: look at using mason tool installer or something. ensure installed only supports lsps, not all the other stuff.
  -- vim.list_extend(ensure_installed, {
  --   'stylua', -- Used to format lua code
  -- })

  require('mason-lspconfig').setup {
    ensure_installed = ensure_installed,
    automatic_enable = true,
    --      handlers = {
    -- function(server_name)
    --   local server = servers[server_name] or {}
    --   -- This handles overriding only values explicitly passed
    --   -- by the server configuration above. Useful when disabling
    --   -- certain features of an LSP (for example, turning off formatting for tsserver)
    --   server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
    --   require('lspconfig')[server_name].setup(server)
    -- end,
    --      },
  }
end
