-- nvim-dap config; setup is deferred to the first dap keypress to keep it
-- off the startup path
local initialized = false
local function ensure_setup()
  if initialized then
    return
  end
  initialized = true
  require('dapui').setup({
    icons = {
      expanded = "▾",
      collapsed = "▸",
    },
  })
  require("nvim-dap-virtual-text").setup({})
end

local dap_maps = {
  { '<leader>dt', function() require('dapui').toggle() end, "Toggle DAP UI" },
  { '<leader>db', function() require('dap').toggle_breakpoint() end, "Toggle breakpoint" },
  { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, "Conditional breakpoint" },
  { '<leader>dc', function() require('dap').continue() end, "Continue" },
  { '<leader>ds', function() require('dap').step_into() end, "Step into" },
  { '<leader>dn', function() require('dap').step_over() end, "Step over" },
  { '<leader>do', function() require('dap').step_out() end, "Step out" },
  { '<leader>dr', function() require('dap').restart() end, "Restart" },
  { '<leader>dl', function() require('dap').repl.open() end, "Open REPL" },
}
for _, map in ipairs(dap_maps) do
  vim.keymap.set('n', map[1], function()
    ensure_setup()
    map[2]()
  end, { silent = true, desc = map[3] })
end
