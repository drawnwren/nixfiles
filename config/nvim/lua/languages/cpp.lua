vim.lsp.config.clangd = {
  on_attach = require("lsp_utils").on_attach,
}

vim.lsp.enable('clangd')
