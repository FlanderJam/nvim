return function(add)
  add({
    source = "mason-org/mason-lspconfig.nvim",
    depends = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "WhoIsSethDaniel/mason-tool-installer.nvim" },
  })

  local mason = require("mason")
  local _ = require("lspconfig")
  local mason_tool_installer = require("mason-tool-installer")
  local mason_lspconfig = require("mason-lspconfig")

  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- This gets sourced from outside of the nvim config repo.
  -- How you source it is up to your discretion.
  --@type ServerConfigMap
  -- local servers = require("nvim-lsp").get_servers(deps)
  local language_tools = require("config.tools")
  local servers = language_tools.language_servers

  local next = next

  for key, value in pairs(servers) do
    if next(value.server_config) then
      vim.lsp.config(key, value.server_config)
    end
    --  Some LSPs (like nushell) are not available on Mason and as a result
    --  will not be enabled by mason_lspconfig below. Instead, we manually enable
    --  them here.
    if value.meta_details.mason == nil then
      vim.lsp.enable(key)
    end
  end

  mason.setup()

  --@type string[]
  local ensure_installed = {}
  for name, server_settings in pairs(servers or {}) do
    if server_settings.meta_details.mason ~= nil and server_settings.meta_details.mason.ensure_installed then
      table.insert(ensure_installed, name)
    end
  end

  mason_lspconfig.setup({
    ensure_installed = ensure_installed,
    automatic_enable = true,
  })

  mason_tool_installer.setup({
    ensure_installed = language_tools:get_non_server_tools_to_install(),
  })
end
