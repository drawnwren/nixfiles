-- telescope config
local ts_opts = {
  extensions = {
    ['ui-select'] = {
      require("telescope.themes").get_dropdown {  }
    }
  }
}
require("telescope").setup(ts_opts)

-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("ui-select")

-- wrap lines instead of horizontal scrolling
vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true  
    vim.opt_local.scrolloff = 0     
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

-- save the original floating preview
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

-- Override it with our own wrapper
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  -- set a border and/or max_width:
  opts.border = opts.border or "rounded"
  opts.max_width = opts.max_width or 80

  -- Call the original function
  local bufnr, winnr = orig_util_open_floating_preview(contents, syntax, opts, ...)

  -- Set wrap-related options on the *window*
  vim.api.nvim_win_set_option(winnr, "wrap", true)
  vim.api.nvim_win_set_option(winnr, "linebreak", true)

  vim.api.nvim_win_set_option(winnr, "number", false)
  vim.api.nvim_win_set_option(winnr, "relativenumber", false)
  vim.api.nvim_win_set_option(winnr, "signcolumn", "no")

  return bufnr, winnr
end

-- open file_browser with the path of the current buffer
vim.api.nvim_set_keymap(
  "n",
  "<space>fb",
  ":Telescope find_files path=%:p:h select_buffer=true<CR>",
  { noremap = true }
)
require('lualine').setup({})
-- {
--   options = {
--     theme = 'catppuccin',
--   }
-- }

-- require("supermaven-nvim").setup({})
-- nvim-cmp config
-- Setup nvim-cmp.
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) 
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ 
      behavior = cmp.ConfirmBehavior.Insert,
      select = true 
    }),
  },

  sources = cmp.config.sources({
    { name = 'supermaven' },
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, 
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Tree Sitter!!
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    disable = function(lang, bufnr) --
      -- Extend this to other languages by adding `lang == "x"` where x is the language
      return lang == "json"
    end,
    additional_vim_regex_highlighting = true,
  },
  indent = {
    enable = true
  },
  incremental_selection = {
    enable = true
  },
  filetype_to_parsername = {
    ["msg"] = "cpp",  -- This associates .msg files with the C++ parser
  },
}

vim.filetype.add({
  extension = {
    msg = "cpp",
  },
})

require("render-markdown").setup({
        file_types = { "markdown", "Avante" },
})

require("avante_lib").load()
require("avante").setup({
  provider = "gemini",
  cursor_applying_provider = "openai_mini",
  openai_mini = {
    endpoint = "https://openrouter.ai/api/v1",
    model = "openai/gpt-4o-mini",
    temperature = 0,
    max_tokens = 8192,
  },
  gemini = {
    endpoint = "https://openrouter.ai/api/v1",
    model = "google/gemini-2.5-pro-preview",
    temperature = 0,
    max_tokens = 8192,
  },
  
})

-- require("codecompanion").setup({
--   prompt_library = require("prompts"),
--   log_level="debug",
--   strategies = {
--     chat = { adapter = "anthropic"
--     --  ollama  = function()
--     --       return require("codecompanion.adapters").extend("anthropic", {
--     --         schema = {
--     --           model = {
--     --             default = "deepseek/deepseek-chat",
--     --           },
--     --           num_ctx = {
--     --             default = 64000,
--     --           },
--     --         },
--     --         headers = {
--     --           ["HTTP-Referer"] = "https://x.com/0xWren",
--     --           ["X-Title"] = "Wren",
--     --         },
--     --         env = {
--     --           url = "https://openrouter.ai/api",
--     --           chat_url = "/v1/chat/completions",
--     --           api_key = "cmd:op read op://personal/OpenRouter/credential --no-newline",
--     --         },
--     --       })
--     -- end,
--     },
--     inline = {
--       adapter = "copilot",
--     },
--   },
--   display = {
--     diff = {
--       provider = "mini_diff",
--     },
--   },
--   opts = {
--     log_level = "DEBUG",
--   },
-- })

vim.api.nvim_set_keymap("n", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
