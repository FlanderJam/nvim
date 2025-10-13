local function new_language_server(mason_opts)
  local language_server = {
    meta_details = {},
    server_config = {},
  }
  if mason_opts ~= nil then
    language_server.meta_details.mason = {}
    if type(mason_opts.ensure_installed) == "boolean" then
      language_server.meta_details.mason.ensure_installed = mason_opts.ensure_installed
    end
  end
  return language_server
end

local T = {
  language_servers = {
    cssls = new_language_server({ ensure_installed = false }),
    denols = (function()
      local ls = new_language_server({ ensure_installed = false })
      ls.server_config = {
        root_dir = function(bufnr, on_dir)
          local match = vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" })
          if match ~= nil then
            on_dir(match)
          end
        end,
      }
      return ls
    end)(),
    emmet_language_server = new_language_server({ ensure_installed = false }),
    gopls = new_language_server({ ensure_installed = false }),
    html = new_language_server({ ensure_installed = false }),
    lua_ls = new_language_server({ ensure_installed = true }),
    nushell = (function()
      local ls = new_language_server()
      ls.server_config = {
        cmd = { "nu", "--lsp" }, -- This pulls the lsp from the nu command running on the shell
        filetypes = { "nu" },
      }
      return ls
    end)(),
    rust_analyzer = new_language_server({ ensure_installed = false }),
    svelte = new_language_server({ ensure_installed = false }),
    tailwindcss = new_language_server({ ensure_installed = false }),
    ts_ls = (function()
      local ls = new_language_server({ ensure_installed = false })
      ls.server_config = {
        root_dir = function(bufnr, on_dir)
          local match = vim.fs.root(bufnr, { "package.json", "package-lock.json" })
          local deno_match = vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" })
          if match ~= nil and deno_match == nil then
            on_dir(match)
          end
        end,
      }
      return ls
    end)(),
    zls = (function()
      local ls = new_language_server()
      ls.server_config = {
        -- omit the following line if `zls` is in your PATH
        cmd = { "/opt/zig/zls/zls" }, -- This zls should be updated when you update your zig nightly
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
            -- zig_exe_path = '/path/to/zig_executable' -- zig is on the path
          },
        },
      }
      return ls
    end)(),
  },

  formatters_by_ft = {
    lua = { ordered_formatters = { "stylua" }, meta_details = { mason = { ensure_installed = true } } },
    javascript = { ordered_formatters = { "prettierd" }, meta_details = { mason = { ensure_installed = false } } },
    javascriptreact = { ordered_formatters = { "prettierd" }, meta_details = { mason = { ensure_installed = false } } },
    typescript = { ordered_formatters = { "prettierd" }, meta_details = { mason = { ensure_installed = false } } },
    typescriptreact = { ordered_formatters = { "prettierd" }, meta_details = { mason = { ensure_installed = false } } },
    svelte = { ordered_formatters = { "prettierd" }, meta_details = { mason = { ensure_installed = false } } },
    css = { ordered_formatters = { "prettierd" }, meta_details = { mason = { ensure_installed = false } } },
    html = { ordered_formatters = { "prettierd" }, meta_details = { mason = { ensure_installed = false } } },
    json = { ordered_formatters = { "prettierd" }, meta_details = { mason = { ensure_installed = false } } },
    yaml = { ordered_formatters = { "prettierd" }, meta_details = { mason = { ensure_installed = false } } },
    markdown = { ordered_formatters = { "prettierd" }, meta_details = { mason = { ensure_installed = false } } },
    graphql = { ordered_formatters = { "prettierd" }, meta_details = { mason = { ensure_installed = false } } },
    go = { ordered_formatters = { "gofmt" }, meta_details = { mason = { ensure_installed = false } } },
    zig = { ordered_formatters = { "zigfmt" }, meta_details = {} },
  },

  linters_by_ft = {
    javascript = { ordered_linters = { "eslint_d" }, meta_details = { mason = { ensure_installed = true } } },
    javascriptreact = { ordered_linters = { "eslint_d" }, meta_details = { mason = { ensure_installed = true } } },
    typescript = { ordered_linters = { "eslint_d" }, meta_details = { mason = { ensure_installed = true } } },
    typescriptreact = { ordered_linters = { "eslint_d" }, meta_details = { mason = { ensure_installed = true } } },
  },

  dap_by_ft = {},
}

local function remove_duplicates(array)
  local hash = {}
  local dupes_removed = {}
  for _, value in ipairs(array) do
    if not hash[value] then
      hash[value] = true
      table.insert(dupes_removed, value)
    end
  end
  return dupes_removed
end

function T:get_servers_list()
  local servers_list = {}
  for server, _ in pairs(self.language_servers) do
    table.insert(servers_list, server)
  end
  return remove_duplicates(servers_list)
end

function T:get_formatters()
  local formatters = {}
  for filetype, language_formatters in pairs(self.formatters_by_ft) do
    formatters[filetype] = language_formatters.ordered_formatters
  end

  local hash = {}
  local dupes_removed = {}
  for filetype, ordered_formatters in pairs(formatters) do
    if not hash[filetype] then
      hash[filetype] = true
      dupes_removed[filetype] = ordered_formatters
    end
  end
  return dupes_removed
end

function T:get_linters()
  local linters = {}
  for filetype, language_linters in pairs(self.linters_by_ft) do
    linters[filetype] = language_linters.ordered_linters
  end

  local hash = {}
  local dupes_removed = {}
  for filetype, ordered_linters in pairs(linters) do
    if not hash[filetype] then
      hash[filetype] = true
      dupes_removed[filetype] = ordered_linters
    end
  end
  return dupes_removed
end

function T:get_non_server_tools_to_install()
  local tools_to_install = {}
  for _, formatters in pairs(self.formatters_by_ft) do
    if formatters.meta_details.mason ~= nil and formatters.meta_details.mason.ensure_installed then
      for _, formatter in ipairs(formatters.ordered_formatters) do
        table.insert(tools_to_install, formatter)
      end
    end
  end
  for _, linters in pairs(self.linters_by_ft) do
    if linters.meta_details.mason ~= nil and linters.meta_details.mason.ensure_installed then
      for _, linter in ipairs(linters.ordered_linters) do
        table.insert(tools_to_install, linter)
      end
    end
  end
  return remove_duplicates(tools_to_install)
end

return T
