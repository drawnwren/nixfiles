local path = require("plenary.path")

local config = require("codecompanion.config")
local log = require("codecompanion.utils.log")
local util = require("codecompanion.utils")
local ts_utils = require("nvim-treesitter.ts_utils")
local ht_hoogle = require("haskell-tools.hoogle")

local fmt = string.format
local Context = {};


---Return when no symbols have been found
local function no_symbols()
  util.notify("No symbols found in the buffer", vim.log.levels.WARN)
end

--------------------------------------------------------------------------------
-- Helper: collect definitions (types, function declarations, references)
--------------------------------------------------------------------------------
local function collect_definitions(root_node)
  local seen = {}
  local definitions = {
    types = {},
    functions = {
      declarations = {}, -- where function is defined
      references = {},   -- where function is used
    },
  }

  local stack = { root_node }
  while #stack > 0 do
    local current = table.remove(stack)
    if current then
      local node_type = current:type()
      -- Collect type information
      if node_type == "type_signature"
          or node_type == "type_constructor"
          or node_type == "qualified_type" then
        -- If the node is a more complex type signature node, keep searching children
        if node_type == "type_signature" then
          for child in current:iter_children() do
            table.insert(stack, child)
          end
        else
          local name = current:named_child(0)
          if name then
            local type_name = vim.treesitter.get_node_text(name, 0)
            if type_name and not seen["type_" .. type_name] then
              seen["type_" .. type_name] = true
              table.insert(definitions.types, type_name)
            end
          end
        end

        -- Collect function declarations
      elseif node_type == "function_declaration" or node_type == "function" then
        local name_node = current:named_child(0)
        if name_node then
          local func_name = vim.treesitter.get_node_text(name_node, 0)
          if func_name and not seen["decl_" .. func_name] then
            seen["decl_" .. func_name] = true
            table.insert(definitions.functions.declarations, func_name)
          end
        end

        -- Collect function references/invocations
      elseif node_type == "variable" or node_type == "identifier" then
        local name = vim.treesitter.get_node_text(current, 0)
        if name and not seen["ref_" .. name] then
          seen["ref_" .. name] = true
          table.insert(definitions.functions.references, name)
        end
      end

      -- Continue DFS with children
      for child in current:iter_children() do
        table.insert(stack, child)
      end
    end
  end
  return definitions
end

--------------------------------------------------------------------------------
-- Main output function
--------------------------------------------------------------------------------
---@param SlashCommand CodeCompanion.Context
local function Context.get_content(context)
  local ft = vim.api.nvim_buf_get_option(0, "ft")
  if ft ~= "haskell" then
    util.notify("This function is only configured for Haskell files currently.", vim.log.levels.WARN)
    return
  end

  -- Read file content
  local file_content = path.new(selected.path):read()
  if not file_content then
    util.notify("Unable to read file content.", vim.log.levels.ERROR)
    return
  end

  -- Treesitter: find the node at cursor
  local cursor_node = ts_utils.get_node_at_cursor()
  if not cursor_node then
    return no_symbols()
  end

  -- Ascend to top-level node if needed
  -- (or at least until we find function or signature)
  local node = cursor_node
  while node:parent() do
    node = node:parent()
  end

  if not node then
    return no_symbols()
  end

  local fun_node, sig_node
  local node_type = node:type()

  if node_type == "bind" or node_type == "function" then
    -- The signature might be the sibling above
    fun_node = node
    sig_node = node:prev_sibling()
    if sig_node and sig_node:type() == "signature" then
      -- good
    else
      -- Or possibly next_sibling
      sig_node = node:next_sibling()
      if sig_node and sig_node:type() ~= "signature" then
        sig_node = nil
      end
    end
  elseif node_type == "signature" then
    -- The function/bind might be the sibling below
    sig_node = node
    fun_node = node:next_sibling()
    if fun_node and not (fun_node:type() == "bind" or fun_node:type() == "function") then
      fun_node = nil
    end
  else
    return no_symbols()
  end

  if not fun_node then
    return no_symbols()
  end

  -- Attempt to get the function name from the function/bind node
  local fun_name_node = fun_node:named_child(0)
  local function_name = fun_name_node and vim.treesitter.get_node_text(fun_name_node, 0)
  if not function_name then
    return no_symbols()
  end

  -- Now collect definitions (types, function declarations, references) within
  -- the function’s subtree
  local definitions = collect_definitions(fun_node)

  -------------------------------------------------------------------------
  --  Hoogle queries for each discovered type and function
  --  NOTE: how you handle concurrency or merging definitions is up to you.
  -------------------------------------------------------------------------
  local hoogle_results = {}

  local function add_hoogle_result(identifier, result)
    -- Feel free to store it in any structure you want or format it
    hoogle_results[#hoogle_results + 1] = {
      id = identifier,
      doc = result or "No definition found",
    }
  end

  local function search_hoogle(str)
    -- uses `haskell-tools.hoogle`
    -- For an async approach, you'd do something like:
    -- ht_hoogle.start(str, function(resp)
    --   add_hoogle_result(str, resp)
    -- end)
    --
    -- For a sync approach, something like:
    local resp_ok, resp = pcall(ht_hoogle.sync_search, str)
    if resp_ok and resp then
      return resp
    end
    return "No definition found"
  end

  -- Query types
  for _, tname in ipairs(definitions.types) do
    local doc = search_hoogle(tname)
    add_hoogle_result(tname, doc)
  end

  -- Query function declarations
  for _, fname in ipairs(definitions.functions.declarations) do
    local doc = search_hoogle(fname)
    add_hoogle_result(fname, doc)
  end

  -- Query function references
  for _, rname in ipairs(definitions.functions.references) do
    local doc = search_hoogle(rname)
    add_hoogle_result(rname, doc)
  end

  -------------------------------------------------------------------------
  --  Finally, populate the LLM prompt
  -------------------------------------------------------------------------
  local prompt_lines = {}
  prompt_lines[#prompt_lines + 1] = fmt(
    "Here is the definition of Haskell function `%s` along with relevant references:\n", function_name)

  if sig_node then
    prompt_lines[#prompt_lines + 1] = "Signature:\n"
    prompt_lines[#prompt_lines + 1] = vim.treesitter.get_node_text(sig_node, 0)
    prompt_lines[#prompt_lines + 1] = "\n\n"
  end

  prompt_lines[#prompt_lines + 1] = "Function Body:\n"
  prompt_lines[#prompt_lines + 1] = vim.treesitter.get_node_text(fun_node, 0)
  prompt_lines[#prompt_lines + 1] = "\n\n"

  if #hoogle_results > 0 then
    prompt_lines[#prompt_lines + 1] = "Below are Hoogle results for relevant types and functions:\n"
    for _, item in ipairs(hoogle_results) do
      prompt_lines[#prompt_lines + 1] = fmt("== %s ==\n%s\n\n", item.id, item.doc)
    end
  end

  local id = "<symbols>" .. selected.relative_path .. "</symbols>"
  local final_content = table.concat(prompt_lines, "\n")

  SlashCommand.Chat:add_message({
    role = config.constants.USER_ROLE,
    content = final_content,
  }, { reference = id, visible = false })

  SlashCommand.Chat.References:add({
    source = "slash_command",
    name = "symbols",
    id = id,
  })

  util.notify(fmt("Added symbols and definitions for `%s` to the chat", vim.fn.fnamemodify(selected.relative_path, ":t")))
end

return Context
