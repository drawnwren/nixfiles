vim.lsp.config.clangd = {
  on_attach = require("lsp_utils").on_attach,
}

vim.lsp.enable('clangd')

-- astyle formatting (PX4 style) via none-ls, when an astyle binary is around
local null_ls = require("null-ls")
local null_ls_utils = require("null-ls.utils")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.astyle.with({
      -- Dynamically add the --options flag with path to .astylerc
      extra_args = function(params)
        local config_path = vim.fn.findfile(".astylerc", params.root .. ";")
        if config_path ~= "" then
          return { "--options=" .. config_path }
        end
        return {}
      end,
      condition = function()
        return vim.fn.executable("astyle") == 1
      end,
    }),
  },
  root_dir = null_ls_utils.root_pattern(
    ".git",
    ".astylerc",
    "Makefile",
    "compile_commands.json"
  ),
})
