local M = {}

local uv = vim.uv or vim.loop

-- Runtime cache entries: key → { data, ts, inflight, waiters }
local _cache = {}

-- Registry for background reload: key → { fn, ttl_ms }
-- Populated by wrap(), used by invalidate to re-prime the cache.
local _registry = {}

--- Internal: run a fetch and store the result. Drains any queued waiters.
-- @param key   string
-- @param fn    function(callback)
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

--- Wrap an async fn(callback) with a TTL cache.
-- If the cached value is fresh, callback is called immediately (scheduled).
-- If a fetch is already in flight, callback is queued and called when it lands.
-- @param key     string  — cache key
-- @param ttl_ms  number  — time-to-live in milliseconds
-- @param fn      function(callback) — original async fetcher
-- @return function(callback) — drop-in cached replacement
function M.wrap(key, ttl_ms, fn)
  _registry[key] = { fn = fn, ttl_ms = ttl_ms }

  return function(callback)
    local entry = _cache[key]
    local now = uv.now()

    -- Cache hit: data present and fresh
    if entry and entry.data ~= nil and (now - entry.ts) < ttl_ms then
      vim.schedule(function()
        callback(entry.data)
      end)
      return
    end

    -- Inflight: another caller is already fetching — queue this callback
    if entry and entry.inflight then
      table.insert(entry.waiters, callback)
      return
    end

    -- Miss: fetch and immediately serve caller via _do_fetch
    -- Inject callback as a waiter so _do_fetch drains it on completion
    _cache[key] = { data = nil, ts = 0, inflight = false, waiters = { callback } }
    _do_fetch(key, fn)
  end
end

--- Invalidate one or more exact cache keys and async-reload them in background.
-- If a fetch is already in flight for a key, skip rescheduling — the in-flight
-- result will land into a fresh entry shortly anyway.
-- @param keys string|string[]
function M.invalidate(keys)
  if type(keys) == "string" then
    keys = { keys }
  end

  for _, k in ipairs(keys) do
    local entry = _cache[k]
    local inflight = entry and entry.inflight
    _cache[k] = nil

    local reg = _registry[k]

    if reg and not inflight then
      local key, fn = k, reg.fn
      vim.schedule(function()
        _do_fetch(key, fn)
      end)
    end
  end
end

--- Invalidate all keys starting with prefix and async-reload each.
-- Same in-flight guard as invalidate() — avoids overlapping fetchers.
-- @param prefix string  e.g. "docker.containers"
function M.invalidate_pattern(prefix)
  local to_reload = {}

  for k, entry in pairs(_cache) do
    if k:find("^" .. prefix) then
      if not entry.inflight then
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

--- Returns true if key has fresh data (cache hit, no fetch needed).
-- Use to gate "Loading..." notifies so they only fire on misses.
-- @param key string
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
