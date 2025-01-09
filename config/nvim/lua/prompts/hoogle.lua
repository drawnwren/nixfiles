local function has_hoogle()
  return vim.fn.executable('hoogle') == 1
end

--@param query string
--@param count number
local function search_hoogle(query, count)
  if not has_hoogle() then
    error("Hoogle executable not found")
    return nil
  end

  count = count or 1
  -- Use --json for structured output
  local command = string.format("hoogle '%s' --count=%d --json", query, count)
  local result = vim.fn.system(command)
  
  -- Parse JSON result
  local ok, parsed = pcall(vim.json.decode, result)
  if not ok then
    return nil
  end
  return parsed
end

--@param query string
--@param count number
--@param callback function
local function search_hoogle_async(query, count, callback)
  if not has_hoogle() then
    error("Hoogle executable not found")
    return
  end

  count = count or 1
  local stdout = {}
  
  local function on_stdout(_, data, _)
    for _, line in ipairs(data) do
      if line ~= "" then
        table.insert(stdout, line)
      end
    end
  end

  local function on_exit(_, _, _)
    local result = table.concat(stdout, "\n")
    local ok, parsed = pcall(vim.json.decode, result)
    if ok then
      callback(parsed)
    else
      callback(nil)
    end
  end

  local command = string.format("hoogle '%s' --count=%d --json", query, count)
  vim.fn.jobstart(command, {
    on_stdout = on_stdout,
    on_exit = on_exit,
  })
end
