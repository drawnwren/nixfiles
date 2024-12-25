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

local opts = {
    on_attach = require("lsp_utils").on_attach,
    before_init = function(_, config)
        config.settings.python.pythonPath = get_python_path()
    end,
    settings = { 
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace"
            }
        },
        pyright = { 
            analysis = { 
                useLibraryCodeForTypes = true, 
                linting = {pylintEnabled = false}
            }
        }
    },
    flags = {
        debounce_text_changes = 200,
    },
}

nvim_lsp.pyright.setup(opts)

-- Null-ls for formatting
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black,
    },
})

-- Ruff configuration
require('lspconfig').ruff.setup {
    on_attach = on_attach, 
    init_options = {
        settings = {
            args = {},
        }
    }
}
