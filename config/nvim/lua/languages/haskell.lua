-- nixos
vim.g.haskell_host_prog = vim.fn.exepath('haskell-language-server-wrapper')

local nvim_lsp = require("lspconfig")
local util = require("lspconfig/util")

-- for nix shells
local function get_haskell_path()
    local haskell_path = vim.fn.system('which haskell-language-server-wrapper'):gsub("\n", "")
    -- Fallback if the which command fails
    if haskell_path == "" then
        haskell_path = vim.g.haskell_host_prog
    end
    return haskell_path
end

local opts = {
    on_attach = require("lsp_utils").on_attach,
    before_init = function(_, config)
        config.settings.haskell.haskellPath = get_haskell_path()
    end,
    settings = {
        haskell = {
            formattingProvider = "ormolu",
            hlintOn = true,
        }
    },
    flags = {
        debounce_text_changes = 200,
    },
}

nvim_lsp.hls.setup(opts)

-- Null-ls for formatting
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.ormolu,
    },
})
