local path = require("plenary.path")

local config = require("codecompanion.config")
local log = require("codecompanion.utils.log")
local util = require("codecompanion.utils")
local ts_utils = require("nvim-treesitter.ts_utils")
local ht_hoogle = require("haskell-tools.hoogle")

local fmt = string.format
local Context = {};


---Return when no symbols have been found
---@param lnum number
local function no_symbols(lnum)
  util.notify(tostring(lnum)..": No symbols found in the buffer", vim.log.levels.WARN)
end

--------------------------------------------------------------------------------
-- Helper: collect definitions (types, function declarations, references)
--------------------------------------------------------------------------------
local function collect_definitions(root_node)
  local seen = {}
  local definitions = {
    types = {},
    functions = {
      declarations = {},
      references = {},   
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
        -- If the node is a more complex type_signature node, keep searching children
        if node_type == "type_signature" then
          for child in current:iter_children() do
            table.insert(stack, child)
          end
        else -- type_constructor, qualified_type
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
function Context.get_content(context)
  local ft = vim.api.nvim_buf_get_option(context.bufnr, "ft")
  if ft ~= "haskell" then
    util.notify("This function is only configured for Haskell files currently.", vim.log.levels.WARN)
    return
  end

  -- Treesitter: find the node at cursor
  local cursor_node = ts_utils.get_node_at_cursor()
  if not cursor_node then
    return no_symbols(100)
  end

  -- Ascend to until we find the function, signature, or bind node
  local node = cursor_node
  while node:parent() and node:type() ~= "bind" and node:type() ~= "function" and node:type() ~= "signature" do
    node = node:parent()
  end

  if not node:parent() then
    return no_symbols(111)
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
    print("Node type: " .. node_type .. " not supported")
    return no_symbols(138)
  end

  if not fun_node then
    return no_symbols(142)
  end

  -- Attempt to get the function name from the function/bind node
  local fun_name_node = fun_node:named_child(0)
  local function_name = fun_name_node and vim.treesitter.get_node_text(fun_name_node, 0)
  if not function_name then
    return no_symbols(149)
  end

  -- Now collect definitions (types, function declarations, references) within
  -- the function’s subtree
  local definitions = collect_definitions(fun_node)
  print("Definitions:")
  print(vim.inspect(definitions))

  -------------------------------------------------------------------------
  --  Hoogle queries for each discovered type and function
  -------------------------------------------------------------------------
  local hoogle_results = {}

  local function add_hoogle_result(identifier, result)
    hoogle_results[#hoogle_results + 1] = {
      id = identifier,
      doc = result or "No definition found",
    }
  end

  local function search_hoogle_async(str, callback)
    -- Use the proper hoogle_signature function
    Hoogle.hoogle_signature({
      search_term = str,
      on_complete = function(resp)  -- Note: You'll need to verify if on_complete is supported
        if resp then
          print("Hoogle result for " .. str)
          print(vim.inspect(resp))
          add_hoogle_result(str, resp)
        else
          add_hoogle_result(str, "No definition found")
        end
        if callback then
          callback()
        end
      end
    })
  end

  local function query_definitions(definitions)
    local pending = 0
    local function on_complete()
      pending = pending - 1
      if pending == 0 then
        -- All async calls are complete
        print("All hoogle searches are complete")
      end
    end

    for _, tname in ipairs(definitions.types) do
      pending = pending + 1
      search_hoogle_async(tname, on_complete)
    end

    for _, fname in ipairs(definitions.functions.declarations) do
      pending = pending + 1
      search_hoogle_async(fname, on_complete)
    end

    for _, rname in ipairs(definitions.functions.references) do
      pending = pending + 1
      search_hoogle_async(rname, on_complete)
    end
  end

  query_definitions(definitions)

  while pending > 0 do
    vim.wait(1)
  end

  print("Hoogle results:")
  print(vim.inspect(hoogle_results))

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

  local id = "<symbols>" .. selected.relative_path() .. "</symbols>"
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

  util.notify(fmt("Added symbols and definitions for `%s` to the chat", vim.fn.fnamemodify(selected.relative_path(), ":t")))
end

return Context
