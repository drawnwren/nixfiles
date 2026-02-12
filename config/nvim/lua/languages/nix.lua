local utils = require("lsp_utils")
local nixpkgs_input = os.getenv("NIXD_NIXPKGS_INPUT") or "nixpkgs"

vim.lsp.config.nixd = {
  on_attach = utils.on_attach,
  settings = {
      nixd = {
          nixpkgs = {
              expr = 'let ctx = import ' .. config_dir .. '/nixd/_nixd-expr.nix { self = "dummy"; }; in if ctx.local != null then ctx.local.inputs.' .. nixpkgs_input .. ' else import <nixpkgs> { }',
          },
          formatting = {
              command = { "nixfmt" },
          },
      }
  }
}

vim.lsp.enable("nixd")
