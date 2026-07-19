local gitsigns = require('gitsigns')

gitsigns.setup({
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    -- hunk navigation (falls back to normal ]c/[c in diff mode)
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({ ']c', bang = true })
      else
        gitsigns.nav_hunk('next')
      end
    end, "Next hunk")
    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({ '[c', bang = true })
      else
        gitsigns.nav_hunk('prev')
      end
    end, "Previous hunk")

    map('n', '<leader>gs', gitsigns.stage_hunk, "Stage hunk")
    map('n', '<leader>gr', gitsigns.reset_hunk, "Reset hunk")
    map('v', '<leader>gs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, "Stage selection")
    map('v', '<leader>gr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, "Reset selection")
    map('n', '<leader>gS', gitsigns.stage_buffer, "Stage buffer")
    map('n', '<leader>gu', gitsigns.undo_stage_hunk, "Undo stage hunk")
    map('n', '<leader>gp', gitsigns.preview_hunk, "Preview hunk")
    map('n', '<leader>gb', function() gitsigns.blame_line({ full = true }) end, "Blame line")
    map('n', '<leader>gd', gitsigns.diffthis, "Diff against index")
  end,
})
