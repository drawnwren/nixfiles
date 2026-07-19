-- rust config via rustaceanvim (no lspconfig setup needed)
vim.g.rustaceanvim = {
  tools = {
    executor = 'termopen',
    test_executor = 'termopen',
    float_win_config = {
      border = "rounded",
      auto_focus = false,
    },
  },

  server = {
    on_attach = require('lsp_utils').on_attach,
    default_settings = {
      ['rust-analyzer'] = {
        check = {
          command = 'clippy',
        },
      },
    },
  },
}
