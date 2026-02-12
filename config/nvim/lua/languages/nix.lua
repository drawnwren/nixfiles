local utils = require("lsp_utils")

vim.lsp.config.nixd = {
  on_attach = utils.on_attach,
  settings = {
      nixd = {}
  }
}

vim.lsp.enable("nixd")
