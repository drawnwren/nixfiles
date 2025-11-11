local lsp_utils = require('lsp_utils')

vim.lsp.config.ts_ls = {
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
  root_markers = { "package.json", "tsconfig.json", ".git" },
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

vim.lsp.enable('ts_ls')
