return function(add)
  add({
    source = "stevearc/conform.nvim",
  })
  local conform = require("conform")
  conform.setup({
    formatters_by_ft = require("config.tools"):get_formatters(),
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },
  })
  vim.keymap.set({ "n", "v" }, "<leader>f", function()
    vim.notify("formatting...")
    conform.format({
      timeout_ms = 500,
      lsp_format = "fallback",
    })
  end, { desc = "Format file or visual selection" })
end
