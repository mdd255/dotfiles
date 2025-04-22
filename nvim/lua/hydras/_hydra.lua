local hydra = require('hydra')

local M = {}

local function conf(opts)
   local default_opts = {
      color    = 'red',
      position = 'middle-right',
      wait     = false,
      timeout  = 6000,
      on_exit  = nil
   }

   opts = opts or {}
   opts.color = opts.color or default_opts.color
   opts.position = opts.position or default_opts.position
   opts.wait = opts.wait or default_opts.wait
   opts.timeout = opts.timeout or default_opts.timeout
   opts.on_exit = opts.on_exit or default_opts.on_exit

   local result = {
      timeout        = opts.timeout,
      color          = opts.color,
      invoke_on_body = true,
      foreign_key    = 'run',
      hint           = {
         position = opts.position,
         float_opts = {
            border = 'rounded'
         }
      }
   }

   if (opts.wait) then
      result.on_key = function()
         vim.wait(50)
      end
   end

   return result
end

local function head_conf(exit)
   return {
      exit   = exit == nil or exit == true,
      silent = true,
      nowait = false
   }
end

local function generate_hint_heads(name, keymap)
   keymap = keymap or {}
   local hint = string.format('---%s----\n\n', name)
   local heads = {}

   for desc, key in pairs(keymap) do
      hint = hint .. string.format('_%s_ %s\n', key.key, desc)
      local is_exit_head = key.exit == nil or key.exit == true

      local head = {
         key.key,
         key.fn,
         head_conf(is_exit_head)
      }

      table.insert(heads, head)
   end

   return hint, heads
end

function M.create(opts)
   opts = opts or {}
   opts.name = opts.name or ''
   opts.mode = opts.mode or 'n'
   opts.keymap = opts.keymap or {}
   opts.keymap.heads = opts.keymap.heads or {}
   opts.conf = opts.conf or {}
   local hint, heads = generate_hint_heads(opts.name, opts.keymap.heads)

   hydra {
      name   = opts.name,
      hint   = hint,
      config = conf(opts.conf),
      mode   = opts.mode,
      body   = opts.keymap.body,
      heads  = heads,
   }
end

return M
