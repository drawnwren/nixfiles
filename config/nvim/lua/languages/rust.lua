-- All of my rust config stuff using rustaceanvim
-- Set updatetime for CursorHold
vim.opt.updatetime = 300

-- Show diagnostic popup on cursor hold
vim.api.nvim_create_autocmd('CursorHold', {
  pattern = '*',
  command = 'lua vim.diagnostic.open_float(nil, {focusable = false})'
})

Config = {}

function Config.config()
    -- rustaceanvim codelldb fancy debugger setup
    local extension_path = '/home/wing/.vscode/extensions/vadimcn.vscode-lldb-1.10.0/'
    local codelldb_path = extension_path .. 'adapter/codelldb'
    local liblldb_path = extension_path .. 'lldb/lib/liblldb.so'

    -- Configure rustaceanvim via vim.g.rustaceanvim
    vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {
            -- Executor for terminal commands
            executor = 'termopen',

            -- Test executor configuration
            test_executor = 'termopen',

            -- Crate graph settings
            crate_graph = {
                backend = 'x11',
                output = nil,
                full = true,
            },

            -- Float window configuration for hover actions
            float_win_config = {
                border = {
                    {"╭", "FloatBorder"}, {"─", "FloatBorder"},
                    {"╮", "FloatBorder"}, {"│", "FloatBorder"},
                    {"╯", "FloatBorder"}, {"─", "FloatBorder"},
                    {"╰", "FloatBorder"}, {"│", "FloatBorder"}
                },
                auto_focus = false,
            },
        },

        -- LSP configuration
        server = {
            on_attach = require('lsp_utils').on_attach,
            default_settings = {
                ['rust-analyzer'] = {
                    cargo = {
                        autoreload = true,
                    },
                    checkOnSave = {
                        command = 'clippy',
                    },
                },
            },
        },

        -- DAP configuration
        dap = {
            adapter = {
                type = 'server',
                port = '${port}',
                host = '127.0.0.1',
                executable = {
                    command = codelldb_path,
                    args = { '--port', '${port}' },
                },
            },
        },
    }
end

Config.config()
return Config
