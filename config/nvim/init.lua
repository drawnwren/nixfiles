vim.loader.enable()

vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "
vim.keymap.set("n", "<Leader>w", ":w<CR>", { silent = true, remap = true })
vim.keymap.set("n", "<Leader>q", ":q<CR>", { silent = true, remap = true })
vim.keymap.set("n", "<Leader>x", ":noh<CR>", { silent = true, remap = true, desc = "Clear highlights" })
vim.keymap.set("n", "<Leader><Leader>", "V", { silent = true, remap = true, desc = "Select line" })

vim.keymap.set("v", "v", "<Plug>(expand_region_expand)", { silent = true, remap = true, desc = "Expand region" })
vim.keymap.set("v", "<C-v>", "<Plug>(expand_region_shrink)", { silent = true, remap = true, desc = "Shrink region" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

vim.opt.ignorecase = true
vim.opt.smartcase = true -- case-sensitive again when the pattern has a capital
vim.opt.inccommand = "split" -- live preview for :s

vim.opt.visualbell = true
vim.opt.scrolloff = 3
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.swapfile = false

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "number"
vim.opt.numberwidth = 3

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- yes, textwidth is a number and colorcolumn is a string. idk why
vim.opt.textwidth = 79
vim.opt.colorcolumn = "80"
vim.opt.formatoptions = "jcroql"

vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
})

local ok, _ = pcall(vim.cmd, 'colorscheme catppuccin')
if not ok then
  vim.cmd 'colorscheme default' -- if the above fails, then use default
end

-- save either by switching buffers or by losing focus
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
      vim.api.nvim_command('silent update')
    end
  end,
})

require("wing")
require("lsp_utils")
require("git")
-- treesitter semantic highlight mappings
require("highlight")

require("wren-dap")

require("whichkey")

-- language specific changes
require("languages/rust")
require("languages/js")
require("languages/python")
require("languages/go")
require("languages/terraform")
require("languages/nix")
require("languages/haskell")
require("languages/lua")
require("languages/shell")
require("languages/cpp")
