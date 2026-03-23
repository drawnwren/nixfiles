require("telescope").setup()

-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("ui-select")
require("telescope").load_extension("file_browser")

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

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  opts.max_width = opts.max_width or 80

  local bufnr, winnr = orig_util_open_floating_preview(contents, syntax, opts, ...)

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
  ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { noremap = true }
)
require('lualine').setup({})
-- {
--   options = {
--     theme = 'catppuccin',
--   }
-- }

-- nvim-cmp config
-- Setup nvim-cmp.
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) 
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ 
      behavior = cmp.ConfirmBehavior.Insert,
      select = true 
    }),
  }),

  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, 
    { name = 'buffer' },
    { name = 'path' },
        
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Tree Sitter!!
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    -- Skip filetypes that don't have parsers
    local excluded = {
      'TelescopePrompt',
      'TelescopeResults',
      'telescope',
      'help',
      'checkhealth',
      'man',
      'gitcommit',
      'gitrebase',
    }
    
    local ft = vim.bo.filetype
    if vim.tbl_contains(excluded, ft) then
      return
    end
    
    -- Try to start treesitter, but don't error if parser doesn't exist
    pcall(vim.treesitter.start)
  end,
})

-- PX4 uses .msg files for their message definitions, but they are essentially
-- C++ headers 
vim.filetype.add({
  extension = {
    msg = "cpp",
  },
})

require("render-markdown").setup({ file_types = { "markdown", "Avante" } })

if #vim.api.nvim_list_uis() > 0 then
  package.loaded["avante.auth.pkce"] = require("avante_pkce")

  local avante_lib_ok, avante_lib = pcall(require, "avante_lib")
  if avante_lib_ok then
    avante_lib.load()
  else
    vim.schedule(function()
      vim.notify("Failed to load avante_lib: " .. tostring(avante_lib), vim.log.levels.WARN)
    end)
  end

  local avante_ok, avante = pcall(require, "avante")
  if avante_ok then
    local setup_ok, setup_err = pcall(avante.setup, {
      provider = "claude",
      input = {
        provider = "dressing",
      },
      providers = {
        claude = {
          auth_type = "max",
        },
      },
      acp_providers = {
        codex = {
          command = "npx",
          args = { "@zed-industries/codex-acp" },
          env = {
            NODE_NO_WARNINGS = "1",
            OPENAI_API_KEY = os.getenv("OPENAI_API_KEY"),
          },
        },
      },
    })

    if not setup_ok then
      vim.schedule(function()
        vim.notify("Avante setup failed: " .. tostring(setup_err), vim.log.levels.WARN)
      end)
    end
  else
    vim.schedule(function()
      vim.notify("Failed to load Avante: " .. tostring(avante), vim.log.levels.WARN)
    end)
  end
end
