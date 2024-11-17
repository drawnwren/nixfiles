local lspconfig = require('lspconfig')
local lsp_utils = require('lsp_utils')

local ts_opts = {
  cmd = { "pnpm", "exec", "typescript-language-server", "--stdio" },
  on_attach = lsp_utils.on_attach,
  init_options = {
    jsx = {
      enabled = true
    }
  },
  filetypes = {
    "typescript",
    "javascript",
    "javascriptreact",
    "typescriptreact"
  },
  root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
  settings = {
    typescript = {
      suggestionActions = {
        enabled = true
      },
      updateImportsOnFileMove = {
        enabled = "always"
      },
    },
    javascript = {
      updateImportsOnFileMove = {
        enabled = "always"
      }
    }
  }
}

lspconfig.ts_ls.setup(ts_opts)
