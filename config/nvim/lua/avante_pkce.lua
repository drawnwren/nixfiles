local M = {}

local function get_random_bytes(n)
  local f, err = io.open("/dev/urandom", "rb")
  if not f then
    return nil, "Failed to open /dev/urandom: " .. tostring(err)
  end

  local bytes = f:read(n)
  f:close()

  if not bytes or #bytes ~= n then
    return nil, "Failed to read secure random bytes from /dev/urandom"
  end

  return bytes, nil
end

local function base64url_encode(data)
  return (vim.base64.encode(data):gsub("+", "-"):gsub("/", "_"):gsub("=", ""))
end

local function hex_to_bytes(hex)
  if type(hex) ~= "string" or #hex % 2 ~= 0 then
    return nil, "Invalid SHA256 digest"
  end

  local ok = true
  local bytes = hex:gsub("..", function(pair)
    local value = tonumber(pair, 16)
    if value == nil then
      ok = false
      return ""
    end
    return string.char(value)
  end)

  if not ok then
    return nil, "Failed to decode SHA256 digest"
  end

  return bytes, nil
end

function M.generate_verifier()
  local bytes, err = get_random_bytes(32)
  if not bytes then
    return nil, err
  end

  return base64url_encode(bytes), nil
end

function M.generate_challenge(verifier)
  local ok, digest = pcall(vim.fn.sha256, verifier)
  if not ok then
    return nil, "Failed to compute SHA256 digest: " .. tostring(digest)
  end

  local bytes, err = hex_to_bytes(digest)
  if not bytes then
    return nil, err
  end

  return base64url_encode(bytes), nil
end

return M
