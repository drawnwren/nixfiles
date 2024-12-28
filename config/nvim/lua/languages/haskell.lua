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


local ht = require('haskell-tools')
local bufnr = vim.api.nvim_get_current_buf()
local opts = { noremap = true, silent = true, buffer = bufnr, }
-- haskell-language-server relies heavily on codeLenses,
-- so auto-refresh (see advanced configuration) is enabled by default
vim.keymap.set('n', '<leader>cl', vim.lsp.codelens.run, opts)
-- Hoogle search for the type signature of the definition under the cursor
vim.keymap.set('n', '<leader>hs', ht.hoogle.hoogle_signature, opts)
-- Evaluate all code snippets
vim.keymap.set('n', '<leader>ea', ht.lsp.buf_eval_all, opts)
-- Toggle a GHCi repl for the current package
vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
-- Toggle a GHCi repl for the current buffer
vim.keymap.set('n', '<leader>rf', function()
  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
end, opts)
vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)
