local uv = vim.loop
local json_decode = (vim.json and vim.json.decode) or vim.fn.json_decode
local json_encode = (vim.json and vim.json.encode) or vim.fn.json_encode

local M = {}

local function read_file(path)
  local fd = io.open(path, "rb")
  if not fd then
    return nil
  end
  local data = fd:read("*a")
  fd:close()
  return data
end

local function write_file(path, data)
  local fd, err = io.open(path, "wb")
  if not fd then
    return nil, err
  end
  fd:write(data)
  fd:close()
  return true
end

local function ensure_dir(path)
  if not path or path == "" then
    return
  end
  if not uv.fs_stat(path) then
    vim.fn.mkdir(path, "p")
  end
end

local function default_tmp_root()
  return vim.env.NIXD_FLAKE_TMP
    or vim.env.TMPDIR
    or vim.fs.joinpath(vim.fn.stdpath("cache"), "nixd-tmp")
end

local function compute_lock_hash(lock_path)
  if not lock_path or vim.fn.filereadable(lock_path) == 0 then
    return nil
  end
  local contents = read_file(lock_path)
  if not contents then
    return nil
  end
  return vim.fn.sha256(contents)
end

local function run_command(cmd, opts)
  opts = opts or {}
  if vim.system then
    local result = vim.system(cmd, {
      text = true,
      env = opts.env,
      cwd = opts.cwd,
    }):wait()
    if result.code ~= 0 then
      local err = result.stderr
      if err == "" then
        err = result.stdout
      end
      return nil, err
    end
    return result.stdout, nil
  end

  local escaped = {}
  for _, part in ipairs(cmd) do
    table.insert(escaped, vim.fn.shellescape(part))
  end
  local prefix = ""
  if opts.env then
    local exports = {}
    for key, value in pairs(opts.env) do
      table.insert(exports, string.format("%s=%s", key, vim.fn.shellescape(value)))
    end
    prefix = "env " .. table.concat(exports, " ") .. " "
  end
  local output = vim.fn.system(prefix .. table.concat(escaped, " "), opts.input)
  if vim.v.shell_error ~= 0 then
    return nil, output
  end
  return output, nil
end

local function copy_tree(src, dst)
  vim.fn.delete(dst, "rf")
  ensure_dir(dst)
  local has_rsync = vim.fn.executable("rsync") == 1
  if has_rsync then
    local ok, err = run_command({ "rsync", "-a", "--delete", src .. "/", dst .. "/" })
    if ok then
      return true
    end
    return nil, err
  end

  local ok, err = run_command({ "cp", "-R", src .. "/.", dst })
  if not ok then
    return nil, err
  end
  return true
end

local function fetch_metadata(flake_dir, cache_home)
  ensure_dir(cache_home)
  local cmd = {
    "nix",
    "--extra-experimental-features",
    "nix-command flakes",
    "flake",
    "metadata",
    "--json",
    flake_dir,
  }
  local stdout, err = run_command(cmd, { env = { XDG_CACHE_HOME = cache_home } })
  if not stdout then
    return nil, err
  end
  local ok, parsed = pcall(json_decode, stdout)
  if not ok then
    return nil, parsed
  end
  return parsed, nil
end

local function cached_info(info_path)
  if vim.fn.filereadable(info_path) == 0 then
    return nil
  end
  local contents = read_file(info_path)
  if not contents then
    return nil
  end
  local ok, decoded = pcall(json_decode, contents)
  if not ok then
    return nil
  end
  return decoded
end

local function store_info(info_path, info)
  local ok, err = write_file(info_path, json_encode(info))
  if not ok then
    return nil, err
  end
  return true
end

local function ensure_cached_flake(opts)
  local tmp_root = opts.tmp_root or default_tmp_root()
  local flakes_root = vim.fs.joinpath(tmp_root, "nixd-flakes")
  local nix_cache = vim.fs.joinpath(tmp_root, "nixd-nix-cache")
  ensure_dir(flakes_root)
  ensure_dir(nix_cache)

  local target_dir = vim.fs.joinpath(flakes_root, opts.lock_hash)
  local source_dir = vim.fs.joinpath(target_dir, "source")
  local info_path = vim.fs.joinpath(target_dir, "info.json")

  local existing = cached_info(info_path)
  if existing and existing.lock_hash == opts.lock_hash and existing.source_dir and uv.fs_stat(existing.source_dir) then
    existing.cache_dir = target_dir
    return existing
  end

  local metadata, err = fetch_metadata(opts.flake_dir, nix_cache)
  if not metadata then
    return nil, err
  end

  local store_path = metadata.path or opts.flake_dir
  ensure_dir(target_dir)
  local ok, copy_err = copy_tree(store_path, source_dir)
  if not ok then
    return nil, copy_err
  end

  local info = {
    lock_hash = opts.lock_hash,
    source_dir = source_dir,
    metadata = metadata,
    cache_dir = target_dir,
  }
  local _, write_err = store_info(info_path, info)
  if write_err then
    return nil, write_err
  end
  return info
end

function M.find_flake(start_dir)
  if not start_dir then
    return nil
  end
  local match = vim.fs.find("flake.nix", { path = start_dir, upward = true })[1]
  return match and vim.fs.dirname(match) or nil
end

function M.prepare(opts)
  opts = opts or {}
  local start_dir = opts.start_dir or vim.loop.cwd()
  local flake_dir = opts.flake_dir or M.find_flake(start_dir)
  if not flake_dir then
    return nil, "Unable to locate flake.nix"
  end
  local lock_path = opts.lock_path or vim.fs.joinpath(flake_dir, "flake.lock")
  local lock_hash = compute_lock_hash(lock_path)

  local cached
  if lock_hash then
    local info, err = ensure_cached_flake({
      flake_dir = flake_dir,
      lock_hash = lock_hash,
      tmp_root = opts.tmp_root,
    })
    cached = info
    if not cached and err then
      vim.schedule(function()
        vim.notify(string.format("nixd: failed to cache flake inputs (%s); using working tree", err), vim.log.levels.WARN)
      end)
    end
  end

  return {
    flake_dir = flake_dir,
    lock_path = lock_path,
    lock_hash = lock_hash,
    self_path = cached and cached.source_dir or flake_dir,
    cache_dir = cached and cached.cache_dir or nil,
    metadata = cached and cached.metadata or nil,
  }
end

return M
