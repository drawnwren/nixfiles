local Context = require("prompts.peg.context")

return {
    {
        role = "system",
        content = function(context)
            return table.concat({
                "I want you to act as a senior Haskell developer. ",
                "I will provide you with a Haskell function, types, and the definitions of the symbols in a file. ",
                "I want you to evaluate the function, types, and definitions for correctness and efficiency. ",
                "You should provide Haskell code back. Please provide corrected code. Only provide code if you see an error.",
                "If you need to add an import, do so inside of a <imports>...</imports> block."
            })
        end
    },
    {
        role = "user",
        content = Context.get_content,
        opts = {
            contains_code = true,
            is_slash_cmd = false
        }
    }
}
