local opts = {
  on_attach = require("lsp_utils").on_attach
}

require'lspconfig'.ts_ls.setup{opts}

