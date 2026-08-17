local cache = require("config.cache")
local M = {}

---@class PickerSize
---@field width? number
---@field height? number

---@class SnacksLayoutOpts: PickerSize
---@field title? string
---@field preview? boolean
---@field fullscreen? boolean
---@field preview_ratio? number

---@param opts SnacksLayoutOpts
function M.custom_layout(opts)
  local preview_ratio = opts.preview_ratio or 0.75

  local size = M.flex_picker_size({
    width = opts.width,
    height = opts.height,
  })

  local layout = {
    fullscreen = opts.fullscreen or false,
    layout = {
      border = "rounded",
      width = size.width,
      height = size.height,
      title = opts.title,
      title_pos = "center",
    },
  }

  if size.is_wide_screen then
    layout.layout.box = "horizontal"

    table.insert(layout.layout, {
      box = "vertical",
      { win = "input", border = "bottom", height = 1 },
      { win = "list", border = "none" },
    })

    if opts.preview then
      table.insert(layout.layout, {
        win = "preview",
        border = "left",
        width = math.floor(layout.layout.width * preview_ratio),
      })
    end
  else
    layout.layout.box = "vertical"

    table.insert(layout.layout, {
      box = "vertical",
      { win = "input", border = "bottom", height = 1 },
      { win = "list", border = "none" },
    })

    if opts.preview then
      local adjusted_height = layout.layout.height * preview_ratio

      if opts.fullscreen then
        adjusted_height = adjusted_height * 3
      end

      table.insert(layout.layout, {
        win = "preview",
        border = "top",
        height = math.floor(adjusted_height),
      })
    end
  end

  return layout
end

M.HL = {
  ok = "DiagnosticOk",
  err = "DiagnosticError",
  warn = "DiagnosticWarn",
  info = "DiagnosticInfo",
  muted = "Comment",
  ident = "Function",
  text = "Text",
}

function M.float_input(prompt, opts, callback)
  local buf = vim.api.nvim_create_buf(false, true)
  local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
  local width = math.min(opts.width or 50, math.floor(ui.width * 0.9))
  local row = math.floor((ui.height - 3) / 2.5)
  local col = math.floor((ui.width - width) / 2)

  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "prompt"
  local prompt_str = " "
  vim.fn.prompt_setprompt(buf, prompt_str)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = prompt,
    title_pos = "center",
  })

  local border_hl = opts.border_hl or "FloatBorder"
  vim.wo[win].winhighlight = "FloatBorder:" .. border_hl .. ",NormalFloat:SnacksInput"

  if opts.secret then
    local ns = vim.api.nvim_create_namespace("float_input_mask")
    vim.wo[win].conceallevel = 2
    vim.wo[win].concealcursor = "nicv"

    vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
      buffer = buf,
      callback = function()
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
        local plen = #prompt_str

        for i = plen + 1, #line do
          vim.api.nvim_buf_set_extmark(buf, ns, 0, i - 1, { end_col = i, conceal = "*" })
        end
      end,
    })
  end

  if opts.default and opts.default ~= "" then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { prompt_str .. opts.default })
  end

  local done = false

  local function finish(value)
    if done then
      return
    end

    done = true

    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end

    vim.schedule(function()
      callback(value or "")
    end)
  end

  vim.fn.prompt_setcallback(buf, function(text)
    finish(text)
  end)

  vim.fn.prompt_setinterrupt(buf, function()
    finish("")
  end)

  vim.keymap.set({ "n", "i" }, "<Esc>", function()
    finish("")
  end, { buffer = buf, silent = true })

  vim.schedule(function()
    vim.cmd("startinsert!")
  end)
end

function M.custom_input(prompt, opts, callback)
  opts = opts or {}
  local size = M.flex_picker_size({ width = opts.width_frac or 0.5 })
  local merged = vim.tbl_extend("force", opts, { width = size.width })
  merged.width_frac = nil
  M.float_input(prompt, merged, callback)
end

function M.confirm_dangerous(prompt, on_confirm)
  M.float_input(prompt .. " Y confirm ", {}, function(input)
    if input and input:lower() == "y" then
      on_confirm()
    else
      vim.notify("Action cancelled", vim.log.levels.INFO, { title = "Confirm" })
    end
  end)
end

local _ts_history = {}

local function _ts_apply(node)
  local sr, sc, er, ec = node:range()

  if vim.fn.mode() ~= "n" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  end

  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, { er + 1, math.max(0, ec - 1) })
end

function M.ts_expand()
  local mode = vim.fn.mode()

  if mode == "n" then
    _ts_history = {}
    local node = vim.treesitter.get_node()

    if not node then
      return
    end

    table.insert(_ts_history, node)
    _ts_apply(node)
    return
  end

  local anchor = vim.fn.getpos("v")
  local cursor = vim.fn.getpos(".")
  local sel_sr = math.min(anchor[2], cursor[2]) - 1
  local sel_sc = math.min(anchor[3], cursor[3]) - 1
  local sel_er = math.max(anchor[2], cursor[2]) - 1
  local sel_ec = math.max(anchor[3], cursor[3]) - 1

  local node = vim.treesitter.get_node({ pos = { sel_sr, sel_sc } })

  while node do
    local nsr, nsc, ner, nec = node:range()
    local nec_inc = nec - 1
    local start_ok = nsr < sel_sr or (nsr == sel_sr and nsc <= sel_sc)
    local end_ok = ner > sel_er or (ner == sel_er and nec_inc >= sel_ec)
    local is_larger = nsr < sel_sr or nsc < sel_sc or ner > sel_er or nec_inc > sel_ec

    if start_ok and end_ok and is_larger then
      break
    end

    node = node:parent()
  end

  if not node then
    return
  end

  table.insert(_ts_history, node)
  _ts_apply(node)
end

function M.ts_shrink()
  table.remove(_ts_history)
  local prev = _ts_history[#_ts_history]

  if not prev then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
    return
  end

  _ts_apply(prev)
end

function M.move_to_start_of_word()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  if line:sub(col + 1, col + 1):match("%w") then
    local s, _ = string.find(line:sub(1, col + 1), "%f[%w]%w*$")

    if s and s - 1 ~= col then
      vim.api.nvim_win_set_cursor(0, { row, s - 1 })
    end
  else
    local keys = vim.api.nvim_replace_termcodes("b", true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
  end
end

function M.create_macro(opts)
  if opts.pre_fn then
    opts.pre_fn()
  end

  local expr = vim.api.nvim_replace_termcodes(opts.expr, true, false, true)
  vim.api.nvim_feedkeys(expr, "n", false)
end

function M.term_cmd(cmd)
  vim.cmd("tabnew")
  vim.cmd("LualineRenameTab " .. cmd)
  vim.cmd("terminal " .. cmd)
  vim.cmd("startinsert")
end

function M.map(lhs, rhs, opts)
  if type(lhs) == "string" then
    lhs = { { lhs, rhs, opts } }
    opts = nil
  end

  local default_opts = opts or {}

  for _, item in ipairs(lhs) do
    if type(item) == "table" and #item >= 2 then
      local key = item[1]
      local command = item[2]
      local key_opts = vim.tbl_deep_extend("force", {}, default_opts, item[3] or {})
      local modes = key_opts.modes or { "n", "x" }
      key_opts.modes = nil

      if type(modes) ~= "table" then
        modes = { modes }
      end

      if key_opts.noremap == nil then
        key_opts.noremap = true
      end

      if key_opts.silent == nil then
        key_opts.silent = true
      end

      if key_opts.expr == nil then
        key_opts.expr = false
      end

      if key_opts.desc == nil then
        key_opts.desc = command
      end

      vim.keymap.set(modes, key, command, key_opts)
    end
  end
end

function M.unmap(lhs, modes)
  if type(lhs) == "string" then
    lhs = { lhs }
  end

  local default_modes = modes or { "n" }

  if type(default_modes) ~= "table" then
    default_modes = { default_modes }
  end

  for _, item in ipairs(lhs) do
    if type(item) == "string" then
      pcall(vim.keymap.del, default_modes, item)
    elseif type(item) == "table" and #item >= 1 then
      local key = item[1]
      local key_modes = item[2] or default_modes

      if type(key_modes) ~= "table" then
        key_modes = { key_modes }
      end

      pcall(vim.keymap.del, key_modes, key)
    end
  end
end

---@param opts PickerSize
---@return { width: number, height: number, is_wide_screen: boolean}
function M.flex_picker_size(opts)
  local ui = vim.api.nvim_list_uis()[1]
  local width = opts.width or 1
  local height = opts.height or 0.4

  local max_width = math.floor(ui.width * 0.95)
  local max_height = math.floor(ui.height * 0.9)

  local is_wide_screen = vim.o.columns > vim.o.lines * 2

  if is_wide_screen then
    return {
      width = math.floor(width * max_width),
      height = math.floor(height * max_height),
      is_wide_screen = is_wide_screen,
    }
  end

  return {
    width = math.min(math.floor(max_width * width * 1.7), max_width),
    height = math.min(math.floor(max_height * height), max_height),
    is_wide_screen = is_wide_screen,
  }
end

function M.parse_json_lines(stdout)
  local out = {}
  local skipped = 0

  for line in (stdout or ""):gmatch("[^\r\n]+") do
    local ok, data = pcall(vim.json.decode, line)

    if ok and data then
      out[#out + 1] = data
    else
      skipped = skipped + 1
    end
  end

  if skipped > 0 then
    vim.notify(skipped .. " malformed JSON line(s) skipped", vim.log.levels.DEBUG, { title = "parse_json_lines" })
  end

  return out
end

function M.picker_selection(picker)
  local selected = picker:selected()

  if #selected == 0 then
    local item = picker:current()

    if item then
      selected = { item }
    end
  end

  return selected
end

local function menu_default_format(item)
  return { { item.text, item.hl or M.HL.text } }
end

function M.menu_picker(items, on_confirm, opts)
  opts = opts or {}

  local confirm = opts.confirm
    or function(picker, item)
      picker:close()

      if item then
        vim.schedule(function()
          on_confirm(item)
        end)
      end
    end

  require("snacks").picker.pick({
    finder = opts.finder or function()
      return items
    end,

    format = opts.format or menu_default_format,

    preview = opts.preview,
    multi = opts.multi,
    actions = opts.actions,
    win = opts.win,

    layout = M.custom_layout({
      title = opts.title or "󱇬 Picker",
      width = opts.width or 0.3,
      height = opts.height or 0.4,
      preview = opts.show_preview,
      preview_ratio = opts.preview_ratio,
      fullscreen = opts.fullscreen,
    }),

    confirm = confirm,
  })
end

function M.make_refresh_action(invalidate_fn, fetch_fn, populate_fn)
  return function(picker)
    invalidate_fn()

    fetch_fn(function(new_data)
      if not new_data then
        return
      end

      populate_fn(new_data)
      picker:refresh()
    end)
  end
end

function M.system_async(cmd, notify_opts, err_msg, parse_fn)
  return function(callback)
    vim.system(cmd, {}, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          local msg = err_msg

          if result.stderr and result.stderr ~= "" then
            msg = msg .. ": " .. result.stderr
          end

          vim.notify(msg, vim.log.levels.ERROR, notify_opts)
          callback(nil)
          return
        end
        callback(parse_fn(result.stdout))
      end)
    end)
  end
end

function M.safe_json_decode(str, err_label, notify_opts)
  local ok, data = pcall(vim.json.decode, str or "[]")

  if not ok or type(data) ~= "table" then
    vim.notify(err_label, vim.log.levels.ERROR, notify_opts)
    return nil
  end

  return data
end

function M.exec_async(cmd, opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    notify = { title = "CMD" },
    info_label = nil,
    success_label = "Command executed",
    failed_label = "Command failed: ",
    suppress_notify = false,
  })

  if opts.info_label then
    vim.notify(opts.info_label, vim.log.levels.INFO, opts.notify)
  end

  vim.system(cmd, { env = opts.env, timeout = opts.timeout }, function(cmd_result)
    vim.schedule(function()
      if cmd_result.code == 0 then
        local message = opts.success_label or ""

        if cmd_result.stdout and cmd_result.stdout ~= "" then
          message = message .. "\n" .. cmd_result.stdout
        end

        if not opts.suppress_notify then
          vim.notify(message, vim.log.levels.INFO, opts.notify)
        end

        if opts.on_success then
          opts.on_success()
        end
      else
        vim.notify(opts.failed_label .. (cmd_result.stderr or "unknown error"), vim.log.levels.ERROR, opts.notify)

        if opts.on_failure then
          opts.on_failure()
        end
      end
    end)
  end)
end

function M.ensure_gh_account(callback)
  vim.system({ "git", "config", "user.name" }, { text = true }, function(git_result)
    if git_result.code ~= 0 then
      vim.schedule(callback)
      return
    end

    local git_user = vim.trim(git_result.stdout or "")

    if git_user == "" then
      vim.schedule(callback)
      return
    end

    vim.system({ "gh", "api", "user", "-q", ".login" }, { text = true }, function(gh_result)
      vim.schedule(function()
        if gh_result.code ~= 0 then
          Snacks.notify(
            "gh auth check failed, skipping account switch: " .. vim.trim(gh_result.stderr or ""),
            { level = vim.log.levels.WARN, title = "gh auth" }
          )
          callback()
          return
        end

        local gh_user = vim.trim(gh_result.stdout or "")

        if gh_user == "" or gh_user == git_user then
          callback()
          return
        end

        vim.system({ "gh", "auth", "switch", "--user", git_user }, { text = true }, function(switch_result)
          vim.schedule(function()
            if switch_result.code ~= 0 then
              Snacks.notify(
                string.format("gh switch failed: '%s' not found", git_user),
                { level = vim.log.levels.WARN, title = "gh auth" }
              )
              callback()
              return
            end

            -- gh auth switch can exit 0 without changing who API calls use
            -- (e.g. GH_TOKEN/GITHUB_TOKEN env var pins the account) so verify.
            vim.system({ "gh", "api", "user", "-q", ".login" }, { text = true }, function(verify_result)
              vim.schedule(function()
                local verified_user = vim.trim(verify_result.stdout or "")

                if verify_result.code == 0 and verified_user == git_user then
                  cache.invalidate({ "gh.current_login" })
                  cache.invalidate_pattern("gh.prs")
                  cache.invalidate_pattern("gh.collaborators")

                  Snacks.notify(
                    string.format("gh: %s → %s", gh_user, git_user),
                    { level = vim.log.levels.INFO, title = "gh auth" }
                  )
                else
                  Snacks.notify(
                    string.format(
                      "gh switch reported success but still authenticated as '%s' — check GH_TOKEN/GITHUB_TOKEN env var",
                      verified_user ~= "" and verified_user or gh_user
                    ),
                    { level = vim.log.levels.ERROR, title = "gh auth" }
                  )
                end

                callback()
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

return M
