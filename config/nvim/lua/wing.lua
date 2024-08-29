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
require("telescope").load_extension("file_browser")


-- open file_browser with the path of the current buffer
vim.api.nvim_set_keymap(
  "n",
  "<space>fb",
  ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { noremap = true }
)
require('lualine').setup {
  options = {
    theme = 'catppuccin',
  }
}


require("supermaven-nvim").setup({})
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
  }
}

require("render-markdown").setup({
        file_types = { "markdown", "Avante" },
})

require("avante").setup({})
