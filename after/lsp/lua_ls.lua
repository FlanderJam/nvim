return {
  on_attach = function(client, _)
    client.server_capabilities.completionProvider.triggerCharacters = { ".", ":", "#", "(" }
  end,
  settings = {
    Lua = {
      workspace = {
        ignoreSubmodules = true,
        checkThirdParty = false,
      },
    },
  },
}
