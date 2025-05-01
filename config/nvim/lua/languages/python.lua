-- nixos
vim.g.python3_host_prog = vim.fn.exepath('python3')

local nvim_lsp = require("lspconfig")
local util = require("lspconfig/util")

-- for nix shells
local function get_python_path()
    local python_path = vim.fn.system('which python'):gsub("\n", "")
    -- Fallback if the which command fails
    if python_path == "" then
        python_path = vim.g.python3_host_prog
    end
    return python_path
end

local function get_pyright_path()
  local python_path = vim.fn.exepath('pyright-langserver') 
  -- fallback or error handle
  if python_path == "" then
    return nil
  end
  return { python_path, "--stdio" }
end

local opts = {
    on_attach = require("lsp_utils").on_attach,
    before_init = function(_, config)
        config.settings.python.pythonPath = get_python_path()
    end,
    -- cmd = get_pyright_path(),
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
                    parameterNames = true
                },
                linting = {pylintEnabled = false}
            }
        },
    },
    flags = {
        debounce_text_changes = 200,
    },
}

nvim_lsp.pyright.setup(opts)

-- Null-ls for formatting
local null_ls = require("null-ls")
local utils = require("null-ls.utils")

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
    }),
    null_ls.builtins.code_actions.shellcheck
  },
  root_dir = utils.root_pattern(
    ".git",        -- Preferred root marker
    ".astylerc",   -- Fallback if no .git folder
    "Makefile",    
    "compile_commands.json"
  ),
})


local function get_ruff_path()
  local ruff_path = vim.fn.exepath('ruff') 
  -- fallback or error handle
  if ruff_path == "" then
    return nil
  end
  return { ruff_path, "server" }
end

-- Ruff configuration
require('lspconfig').ruff.setup {
    on_attach = require("lsp_utils").on_attach,
    cmd = get_ruff_path(),
    single_file_support = true,
    filetypes = { "python" },
    settings = {
      interpreter = { vim.fn.exepath("python") }
    },
    root_dir = util.find_git_ancestor(fname),
    before_init = function(_, config)
      if not config.settings then
        config.settings = {}
      end
      if not config.settings.python then
        config.settings.python = {}
      end
      config.settings.python.pythonPath = os.getenv("PYTHONPATH") or vim.fn.exepath("python3")
    end
}
