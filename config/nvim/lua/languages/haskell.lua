local util = require("lspconfig/util")
local ht = require('haskell-tools')

local iron = require("iron.core")
iron.setup {
  config = {
    repl_definition = {
      haskell = {
        command = function(meta)
          local file = vim.api.nvim_buf_get_name(meta.current_bufnr)
          -- call `require` in case iron is set up before haskell-tools
          return require('haskell-tools').repl.mk_repl_cmd(file)
        end,
      },
    },
    repl_open_cmd = "vsplit", -- Set vsplit directly as the default
  },
}

local function hs_attach(client, bufnr, ht)
  local bufnr = vim.api.nvim_get_current_buf()
  local opts = { noremap = true, silent = true, buffer = bufnr, }
  -- Hoogle web search for the symbol under the cursor
  vim.keymap.set('n', '<leader>hw', function()
    local word = vim.fn.expand('<cword>')
    vim.fn.system('open "https://hoogle.haskell.org/?hoogle=' .. word .. '"')
  end, opts)
  -- haskell-language-server relies heavily on codeLenses,
  -- so auto-refresh (see advanced configuration) is enabled by default
  vim.keymap.set('n', '<leader>hl', vim.lsp.codelens.run, opts)
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
  require("lsp_utils").on_attach(client, bufnr)
end 

vim.g.haskell_tools = {
  hls = {
    --@param ht HaskellTools = require('haskell-tools')
    on_attach = function(client, bufnr, ht)
      hs_attach(client, bufnr, ht)
    end,
    settings = {
      haskell = {
        plugin = {
          hlint = {
            codeActionsOn = false,
            diagnosticsOn = false,
          },
          fourmolu = {
            config = {
              external = true;
            },
          }, 
        },
        formattingProvider = "fourmolu",
      },
    },
  },
}

