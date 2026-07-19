-- module for my lsp common configurations. invidividual lsp config still
-- happens in each language.lua file
local utils = {}

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { silent = true, desc = "Open diagnostics" })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, { silent = true, desc = "Go to previous diagnostic" })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, { silent = true, desc = "Go to next diagnostic" })

local format_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = false })

-- format on save unless toggled off (:FormatToggle globally, :FormatToggle! per buffer)
vim.api.nvim_create_user_command("FormatToggle", function(opts)
  if opts.bang then
    vim.b.autoformat = vim.b.autoformat == false
    vim.notify("format on save (buffer): " .. tostring(vim.b.autoformat))
  else
    vim.g.autoformat = vim.g.autoformat == false
    vim.notify("format on save (global): " .. tostring(vim.g.autoformat))
  end
end, { bang = true, desc = "Toggle format on save (! = buffer only)" })

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
function utils.on_attach(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- clear first so a second server attaching doesn't format twice
  vim.api.nvim_clear_autocmds({ group = format_group, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = format_group,
    buffer = bufnr,
    callback = function(args)
      if vim.g.autoformat == false or vim.b[args.buf].autoformat == false then
        return
      end
      vim.lsp.buf.format()
    end,
  })

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local maps = {
    { 'gD', vim.lsp.buf.declaration, "Go to declaration" },
    { 'gd', vim.lsp.buf.definition, "Go to definition" },
    { 'K', vim.lsp.buf.hover, "Hover" },
    { 'gi', vim.lsp.buf.implementation, "Go to implementation" },
    { '<C-k>', vim.lsp.buf.signature_help, "Signature help" },
    { '<space>wa', vim.lsp.buf.add_workspace_folder, "Add workspace folder" },
    { '<space>wr', vim.lsp.buf.remove_workspace_folder, "Remove workspace folder" },
    { '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, "List workspace folders" },
    { '<space>D', vim.lsp.buf.type_definition, "Go to type definition" },
    { '<space>rn', vim.lsp.buf.rename, "Rename" },
    { '<space>ca', vim.lsp.buf.code_action, "Code action" },
    { 'gr', vim.lsp.buf.references, "Go to references" },
    { '<space>f', vim.lsp.buf.format, "Format" },
  }
  for _, map in ipairs(maps) do
    vim.keymap.set('n', map[1], map[2], { buffer = bufnr, silent = true, desc = map[3] })
  end
end

return utils
