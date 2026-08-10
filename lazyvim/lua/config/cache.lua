local M = {}

local uv = vim.uv or vim.loop
local _cache = {}
local _registry = {}

local function _do_fetch(key, fn)
  local entry = _cache[key]

  -- Already fetching — skip, waiters will be served when it lands
  if entry and entry.inflight then
    return
  end

  _cache[key] = { data = nil, ts = 0, inflight = true, waiters = entry and entry.waiters or {} }

  fn(function(data)
    local e = _cache[key]

    if e then
      e.data = data
      e.ts = uv.now()
      e.inflight = false

      for _, waiter in ipairs(e.waiters) do
        local w, d = waiter, data
        vim.schedule(function()
          w(d)
        end)
      end

      e.waiters = {}
    end
  end)
end

function M.wrap(key, ttl_ms, fn)
  _registry[key] = { fn = fn, ttl_ms = ttl_ms }

  return function(callback)
    local entry = _cache[key]
    local now = uv.now()

    if entry and entry.data ~= nil and (now - entry.ts) < ttl_ms then
      vim.schedule(function()
        callback(entry.data)
      end)
      return
    end

    if entry and entry.inflight then
      table.insert(entry.waiters, callback)
      return
    end

    _cache[key] = { data = nil, ts = 0, inflight = false, waiters = { callback } }
    _do_fetch(key, fn)
  end
end

function M.wrap_filters(filters, ttl, key_fn, fetcher_fn)
  local fetchers = {}
  for _, f in ipairs(filters) do
    local key = key_fn(f)
    fetchers[key] = M.wrap(key, ttl, fetcher_fn(f))
  end
  return fetchers
end

function M.invalidate(keys)
  if type(keys) == "string" then
    keys = { keys }
  end

  for _, k in ipairs(keys) do
    local entry = _cache[k]
    _cache[k] = nil

    if entry and entry.inflight then
      for _, w in ipairs(entry.waiters or {}) do
        vim.schedule(function()
          w(nil)
        end)
      end
    else
      local reg = _registry[k]
      if reg then
        local key, fn = k, reg.fn
        vim.schedule(function()
          _do_fetch(key, fn)
        end)
      end
    end
  end
end

function M.evict_pattern(prefix)
  for k, entry in pairs(_cache) do
    if k:sub(1, #prefix) == prefix and not entry.inflight then
      _cache[k] = nil
    end
  end
end

function M.invalidate_pattern(prefix)
  local to_reload = {}

  for k, entry in pairs(_cache) do
    if k:sub(1, #prefix) == prefix then
      if entry.inflight then
        for _, w in ipairs(entry.waiters or {}) do
          vim.schedule(function()
            w(nil)
          end)
        end
      else
        table.insert(to_reload, k)
      end
      _cache[k] = nil
    end
  end

  for _, k in ipairs(to_reload) do
    local reg = _registry[k]

    if reg then
      local key, fn = k, reg.fn
      vim.schedule(function()
        _do_fetch(key, fn)
      end)
    end
  end
end

function M.is_cached(key)
  local entry = _cache[key]
  if not entry or entry.data == nil then
    return false
  end
  local reg = _registry[key]
  if not reg then
    return false
  end
  return (uv.now() - entry.ts) < reg.ttl_ms
end

return M
