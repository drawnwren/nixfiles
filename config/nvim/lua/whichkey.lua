local wk = require("which-key")

wk.setup({
  plugins = {
    presets = {
      operators = true,
    },
  },
  triggers = {
    { "<auto>", mode = "nxsot" },
  },
})

wk.add({
  { "<leader>f", group = "find" },
  { "<leader>d", group = "debug" },
  { "<leader>g", group = "git" },
  { "<leader>h", group = "haskell" },
  { "<leader>r", group = "repl" },
})
