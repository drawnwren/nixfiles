local utils = require("lsp_utils")

local json_encode = (vim.json and vim.json.encode) or vim.fn.json_encode
local trim = (vim.trim or function(value)
  return (value and value:match("^%s*(.-)%s*$")) or value
end)

local function script_path()
  local source = debug.getinfo(1, "S").source
  if source:sub(1, 1) == "@" then
    source = source:sub(2)
  end
  return vim.fs.normalize(source)
end

local current_script = script_path()
local languages_dir = vim.fs.dirname(current_script)
local lua_dir = vim.fs.dirname(languages_dir)
local nvim_dir = vim.fs.dirname(lua_dir)
local config_dir = vim.fs.dirname(nvim_dir)
local expr_module = vim.fs.joinpath(nvim_dir, "nixd", "_nixd-expr.nix")

local function embedded_cache_module()
  local uv = vim.loop
  local json_decode = (vim.json and vim.json.decode) or vim.fn.json_decode
  local json_encode = (vim.json and vim.json.encode) or vim.fn.json_encode

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

  local M = {}

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
end

local function load_cache_module()
  local ok, mod = pcall(require, "nixd.cache")
  if ok then
    return mod
  end

  local fallback_path = vim.fs.joinpath(lua_dir, "nixd", "cache.lua")
  if vim.loop.fs_stat(fallback_path) then
    local chunk, err = loadfile(fallback_path)
    if chunk then
      local module = chunk()
      package.preload["nixd.cache"] = function()
        return module
      end
      return module
    else
      vim.notify(string.format("nixd: failed to load cache helper (%s); using embedded fallback", err or "unknown error"), vim.log.levels.WARN)
    end
  end

  local module = embedded_cache_module()
  package.preload["nixd.cache"] = function()
    return module
  end
  return module
end

local cache = load_cache_module()

if not vim.loop.fs_stat(expr_module) then
  vim.notify(string.format("nixd helper not found at %s", expr_module), vim.log.levels.ERROR)
  return
end

local flake_opts = {}
local override_root = vim.env.NIXD_FLAKE_ROOT
if override_root and override_root ~= "" then
  flake_opts.flake_dir = vim.fs.normalize(override_root)
else
  flake_opts.start_dir = config_dir
end

local flake_context, flake_err = cache.prepare(flake_opts)
if not flake_context then
  vim.notify(string.format("nixd: %s", flake_err or "failed to prepare flake context"), vim.log.levels.ERROR)
  return
end

local function detect_system()
  local uname = vim.loop.os_uname()
  local arch = uname.machine
  if arch == "arm64" then arch = "aarch64" end
  if arch == "amd64" then arch = "x86_64" end
  local kernel = uname.sysname
  if kernel == "Darwin" then
    kernel = "darwin"
  else
    kernel = "linux"
  end
  return string.format("%s-%s", arch, kernel)
end

local system_name = vim.env.NIXD_SYSTEM or detect_system()
local self_flake = vim.fs.normalize(flake_context.self_path or flake_context.flake_dir)
local expr_module_literal = string.format("%q", vim.fs.normalize(expr_module))

local function with_flakes(expr)
  return string.format(
    [[with import %s { self = %s; system = %s; }; %s]],
    expr_module_literal,
    json_encode(self_flake),
    json_encode(system_name),
    expr
  )
end

local function split_segments(value)
  if not value or value == "" then
    return nil
  end
  local segments = {}
  for _, part in ipairs(vim.split(value, ".", { trimempty = true })) do
    local cleaned = trim(part)
    if cleaned ~= "" then
      table.insert(segments, cleaned)
    end
  end
  if #segments == 0 then
    return nil
  end
  return segments
end

local function nix_list_literal(parts)
  if not parts or #parts == 0 then
    return "[ ]"
  end
  local quoted = {}
  for _, part in ipairs(parts) do
    table.insert(quoted, string.format("%q", part))
  end
  return string.format("[ %s ]", table.concat(quoted, " "))
end

local function attr_expr_from_path(path_segments, suffix_segments)
  local base = string.format("builtins.tryEval (builtins.getAttrFromPath %s global)", nix_list_literal(path_segments))
  if not suffix_segments or #suffix_segments == 0 then
    return string.format([[
let
  target = %s;
in
if target.success then target.value else null
]], base)
  end

  return string.format([[
let
  target = %s;
in
if target.success then
  let final = builtins.tryEval (builtins.getAttrFromPath %s target.value);
  in if final.success then final.value else null
else
  null
]], base, nix_list_literal(suffix_segments))
end

local function resolve_default_suffix()
  local env_value = vim.env.NIXD_TARGET_SUFFIX
  if env_value == "" then
    return nil
  elseif env_value then
    return split_segments(env_value)
  else
    return split_segments("options")
  end
end

local default_suffix_segments = resolve_default_suffix()

local function parse_target_list(default_suffix)
  local targets = {}
  local multi = vim.env.NIXD_TARGETS
  if multi and multi ~= "" then
    for entry in multi:gmatch("([^;]+)") do
      local label, remainder = entry:match("^([^=]+)=(.+)$")
      if label and remainder then
        local path_part, suffix_part = remainder:match("^([^:]+):(.*)$")
        local suffix_segments
        local override_suffix = false
        local explicit_none = false
        if path_part then
          override_suffix = true
          if suffix_part == "" then
            explicit_none = true
          else
            suffix_segments = split_segments(suffix_part)
          end
        else
          path_part = remainder
        end
        if not override_suffix then
          suffix_segments = default_suffix
        elseif explicit_none then
          suffix_segments = nil
        elseif not suffix_segments then
          suffix_segments = default_suffix
        end
        local segments = split_segments(path_part)
        if segments then
          table.insert(targets, {
            label = trim(label),
            path = segments,
            suffix = suffix_segments or default_suffix,
          })
        end
      end
    end
  end

  local single_attr = vim.env.NIXD_TARGET_ATTR
  if single_attr and single_attr ~= "" then
    local suffix_env = vim.env.NIXD_TARGET_SUFFIX
    local suffix_segments
    if suffix_env == "" then
      suffix_segments = nil
    elseif suffix_env then
      suffix_segments = split_segments(suffix_env)
    else
      suffix_segments = default_suffix
    end
    local singular_segments = split_segments(single_attr)
    if singular_segments then
      table.insert(targets, {
        label = vim.env.NIXD_TARGET_LABEL or "target",
        path = singular_segments,
        suffix = suffix_segments,
      })
    end
  end

  return targets
end

local function detect_system_host()
  local host = vim.env.NIXD_NIXOS_HOST
  if host and host ~= "" then
    return host
  end
  return nil
end

local nixos_host = detect_system_host()
local target_specs = parse_target_list(default_suffix_segments)

local nixpkgs_expr = with_flakes([[import (if local ? lib.version then local else local.inputs.nixpkgs or global.inputs.nixpkgs) { }]])
local flake_parts_expr = with_flakes("local.debug.options or global.debug.options")

local function nixos_options_expr(host)
  return with_flakes(string.format([[
let
  cfgs = global.nixosConfigurations or { };
  host = %s;
in
if builtins.hasAttr host cfgs then
  (builtins.getAttr host cfgs).options
else
  null
]], json_encode(host)))
end

local function home_manager_options_expr(host)
  return with_flakes(string.format([[
let
  cfgs = global.nixosConfigurations or { };
  host = %s;
in
if builtins.hasAttr host cfgs then
  let opts = (builtins.getAttr host cfgs).options;
  in if builtins.hasAttr "home-manager" opts && opts."home-manager" ? users && opts."home-manager".users ? type then
    opts."home-manager".users.type.getSubOptions [ ]
  else
    null
else
  null
]], json_encode(host)))
end

local function nixvim_options_expr()
  return with_flakes(string.format([[
let
  cfgs = global.nixvimConfigurations or { };
  system = %s;
in
if builtins.hasAttr system cfgs then
  let selected = builtins.tryEval (builtins.getAttr system cfgs);
  in if selected.success && selected.value ? default && selected.value.default ? options then
    selected.value.default.options
  else
    null
else
  null
]], json_encode(system_name)))
end

local options_section = {
  ["flake-parts"] = { expr = flake_parts_expr },
  nixvim = { expr = nixvim_options_expr() },
}

if nixos_host then
  options_section.nixos = { expr = nixos_options_expr(nixos_host) }
  options_section["home-manager"] = { expr = home_manager_options_expr(nixos_host) }
end

for _, target in ipairs(target_specs) do
  if target.path then
    local expr = attr_expr_from_path(target.path, target.suffix)
    options_section[target.label] = { expr = with_flakes(expr) }
  end
end

vim.lsp.config.nixd = {
  on_attach = utils.on_attach,
  settings = {
    nixd = {
      nixpkgs = {
        expr = nixpkgs_expr,
      },
      options = options_section,
      diagnostic = {
        suppress = {
          "sema-escaping-with",
          "var-bind-to-this",
        },
      },
    },
  },
}

vim.lsp.enable("nixd")
