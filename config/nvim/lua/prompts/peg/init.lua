

local Peg = {
  strategy = "chat",
  description = "Peg a hole in your code",
  opts = {
    mapping = "<Leader>hp",
    modes = { "v" },
    short_name = "peg",
    auto_submit = true,
    stop_context_insertion = true,
    user_prompt = true,
  },
  prompts = require("prompt"),
}
