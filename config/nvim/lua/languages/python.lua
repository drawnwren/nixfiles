vim.g.python3_host_prog = vim.fn.exepath('python3')

-- resolve the interpreter from PATH so nix shells / venvs win
local function get_python_path()
  local python_path = vim.fn.exepath('python')
  if python_path == "" then
    python_path = vim.g.python3_host_prog
  end
  return python_path
end

vim.lsp.config.basedpyright = {
  on_attach = require("lsp_utils").on_attach,
  before_init = function(_, config)
    config.settings.python = config.settings.python or {}
    config.settings.python.pythonPath = get_python_path()
  end,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          callArgumentNames = true,
          parameterNames = true,
        },
      },
    },
  },
  flags = {
    debounce_text_changes = 200,
  },
}

vim.lsp.enable('basedpyright')

vim.lsp.config.ruff = {
  on_attach = require("lsp_utils").on_attach,
  single_file_support = true,
  before_init = function(_, config)
    config.settings = config.settings or {}
    config.settings.python = config.settings.python or {}
    config.settings.python.pythonPath = get_python_path()
  end,
}

vim.lsp.enable('ruff')
