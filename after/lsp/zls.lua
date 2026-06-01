return {
  -- only needed if zls isn't on your $PATH
  --cmd = { "/opt/zig/zls/zls" }, -- This zls should be updated when you update your zig nightly

  settings = {
    zls = {
      -- enable_inlay_hints = true,
      -- inlay_hints_show_builtin = true,
      -- enable_snippets = true,
      -- zig_exe_path = "/path/to/zig",
    },
  },
}
