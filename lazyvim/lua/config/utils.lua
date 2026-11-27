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
        local parts = {}

        for _, stream in ipairs({ cmd_result.stderr, cmd_result.stdout }) do
          local t = vim.trim(stream or "")

          if t ~= "" then
            table.insert(parts, t)
          end
        end

        local detail = #parts > 0 and table.concat(parts, "\n") or "unknown error"

        local reason = cmd_result.signal and cmd_result.signal ~= 0 and (" signal " .. cmd_result.signal) or ""

        vim.notify(
          string.format(
            "%s%s\n[exit %s%s] $ %s",
            opts.failed_label,
            detail,
            tostring(cmd_result.code),
            reason,
            table.concat(cmd, " ")
          ),
          vim.log.levels.ERROR,
          opts.notify
        )

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

local FORM_NS = vim.api.nvim_create_namespace("UtilsForm")

-- statuscolumn for M.form: plain gutter, but separator rows draw ── so they meet the border
function M._form_statuscol()
  local ok, sep_row = pcall(vim.api.nvim_win_get_var, vim.g.statusline_winid, "form_sep_row")

  if vim.v.virtnum < 0 or (ok and vim.v.virtnum == 0 and vim.v.lnum == sep_row) then
    return "%#FloatBorder#──%*"
  end

  return "  "
end

local function form_normalize_items(list)
  local out = {}

  for _, it in ipairs(list or {}) do
    if type(it) == "string" then
      table.insert(out, { word = it })
    elseif it.word and it.word ~= "" then
      table.insert(out, it)
    end
  end

  return out
end

-- Single float form: one line per field (+ optional multi-line body).
-- opts = {
--   title = " icon  Title ", submit_label = "create", width = 0.7 (fraction), notify_title = "...",
--   extra_height = 0 (extra rows below the fields, body-less forms),
--   fields = { {
--     key, label, icon, value, hint, required,
--     compact = true,  -- comma separated value, whitespace stripped, completes the last segment
--     items = list | function(cb, data) cb(list) end,  -- completion menu entries: "str" | { word, menu }
--   } },
--   body = { hint = "placeholder" } | nil,
--   on_submit = function(data) end,
--   on_change = function(data) end,  -- optional: after every text edit (live preview)
--   on_close = function() end,       -- optional: form buffer wiped (submit or cancel)
-- }
-- Keys: <C-n>/<C-e> next/prev field, <Tab>/<S-Tab> walk completion menu, <CR> accept / next / submit,
-- <C-CR> submit, q (normal) cancel.
function M.form(opts)
  local fields = opts.fields
  local nf = #fields
  local has_body = opts.body ~= nil
  local sep_row = nf + 1
  local body_row = nf + 2
  local min_lines = has_body and body_row or nf
  local any_items = false

  for _, f in ipairs(fields) do
    any_items = any_items or f.items ~= nil
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = has_body and "markdown" or "text"

  local init = {}

  for i, f in ipairs(fields) do
    init[i] = f.value or ""
  end

  while #init < min_lines do
    table.insert(init, "")
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, init)

  local label_w = 0

  for _, f in ipairs(fields) do
    label_w = math.max(label_w, vim.fn.strdisplaywidth(f.label))
  end

  local function label_text(f)
    return string.format("%s  %s", f.icon or " ", f.label .. string.rep(" ", label_w - vim.fn.strdisplaywidth(f.label)))
  end

  local join_col = vim.fn.strdisplaywidth(label_text(fields[1])) + 1
  local text_off = 2 + (join_col - 1) + 3 -- gutter + label + " │ ": where field text starts in the window

  local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
  local width = math.floor(ui.width * (opts.width or (has_body and 0.7 or 0.5)))
  local height = has_body and math.floor(ui.height * 0.65) or (nf * 2 + (opts.extra_height or 0)) -- fields + separators + one empty line

  local footer = {
    { " <C-CR>", "DiagnosticOk" },
    { " " .. (opts.submit_label or "confirm") .. "  ", "Comment" },
  }

  if any_items then
    vim.list_extend(footer, { { "<Tab>", "DiagnosticWarn" }, { " choose ", "Comment" } })
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((ui.height - height) / 2),
    col = math.floor((ui.width - width) / 2),
    style = "minimal",
    border = "rounded",
    title = { { opts.title or " Form ", "DiagnosticInfo" } },
    title_pos = "center",
    footer = footer,
    footer_pos = "center",
  })

  vim.b[buf].completion = false -- blink.cmp off: the form drives its own completion menu
  vim.w[win].form_sep_row = has_body and sep_row or -1
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].cursorline = false
  vim.wo[win].statuscolumn = "%!v:lua.require'config.utils'._form_statuscol()"
  vim.wo[win].winhighlight = "FloatBorder:DiagnosticInfo"

  local function render()
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    while vim.api.nvim_buf_line_count(buf) < min_lines do
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
    end

    vim.api.nvim_buf_clear_namespace(buf, FORM_NS, 0, -1)

    local lines = vim.api.nvim_buf_get_lines(buf, 0, nf, false)
    local w = (vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_width(win) or width) - 2

    -- horizontal rule across the window; junction sits under the label/value divider
    local function rule(junction)
      return string.rep("─", join_col) .. junction .. string.rep("─", math.max(w - join_col - 1, 0))
    end

    for i, f in ipairs(fields) do
      vim.api.nvim_buf_set_extmark(buf, FORM_NS, i - 1, 0, {
        virt_text = { { label_text(f), "DiagnosticInfo" }, { " │ ", "FloatBorder" } },
        virt_text_pos = "inline",
        right_gravity = false,
      })

      if (lines[i] or "") == "" then
        local hint = f.hint or (f.items and "<Tab> to choose" or "")

        vim.api.nvim_buf_set_extmark(buf, FORM_NS, i - 1, 0, {
          virt_text = { { hint, "Comment" } },
          virt_text_pos = "eol",
        })
      end

      if i < nf then
        vim.api.nvim_buf_set_extmark(buf, FORM_NS, i - 1, 0, {
          virt_lines = { { { rule("┼"), "FloatBorder" } } },
        })
      end
    end

    if has_body then
      vim.api.nvim_buf_set_extmark(buf, FORM_NS, sep_row - 1, 0, {
        virt_text = { { rule("┴"), "FloatBorder" } },
        virt_text_pos = "overlay",
      })

      if (vim.api.nvim_buf_get_lines(buf, body_row - 1, body_row, false)[1] or "") == "" then
        vim.api.nvim_buf_set_extmark(buf, FORM_NS, body_row - 1, 0, {
          virt_text = { { opts.body.hint or "", "Comment" } },
          virt_text_pos = "eol",
        })
      end
    end
  end

  render()

  local function parse()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local data = {}

    for i, f in ipairs(fields) do
      local v = vim.trim(lines[i] or "")

      if f.compact then
        v = v:gsub("%s+", "")
      end

      data[f.key] = v
    end

    if has_body then
      data.body = vim.trim(table.concat(vim.list_slice(lines, body_row), "\n"))
    end

    return data
  end

  -- text of all fields; TextChangedI also fires once when insert mode starts and after our own edits,
  -- so only react when the text really differs from this snapshot
  local function snapshot_text()
    return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  end

  local snapshot = snapshot_text()

  local function notify_change()
    if opts.on_change then
      opts.on_change(parse())
    end
  end

  -- own completion menu: a float whose first entry sits on the line below the cursor
  local menu = { buf = nil, win = nil, items = {}, sel = 0, start = 1 }
  local MENU_NS = vim.api.nvim_create_namespace("UtilsFormMenu")

  local function menu_open()
    return menu.win ~= nil and vim.api.nvim_win_is_valid(menu.win)
  end

  local function menu_close()
    if menu_open() then
      vim.api.nvim_win_close(menu.win, true)
    end

    menu.win = nil
    menu.items = {}
    menu.sel = 0
  end

  local function menu_hl(name, fallback)
    return vim.fn.hlexists(name) == 1 and name or fallback
  end

  local MENU_ICON = "󰉿" -- blink "Text" kind icon

  -- same layout as blink: " <icon>  label desc ", matched chars highlighted, long entries cut to one line
  local function menu_fit(text, max)
    if max <= 0 then
      return ""
    end

    if vim.fn.strdisplaywidth(text) <= max then
      return text
    end

    return vim.fn.strcharpart(text, 0, math.max(max - 1, 0)) .. "…"
  end

  local function menu_draw()
    local lines, parts = {}, {}
    local prefix = " " .. MENU_ICON .. "  "
    local avail = menu.width - vim.fn.strdisplaywidth(prefix) - 1

    vim.api.nvim_buf_clear_namespace(menu.buf, MENU_NS, 0, -1)

    for i, it in ipairs(menu.items) do
      local word = menu_fit(it.word, avail)
      local desc = ""

      if it.menu and it.menu ~= "" then
        local room = avail - vim.fn.strdisplaywidth(word) - 1

        if room >= 2 then
          desc = menu_fit(it.menu, room)
        end
      end

      parts[i] = { word = word, desc = desc }
      lines[i] = prefix .. word .. (desc ~= "" and (" " .. desc) or "") .. " "
    end

    vim.api.nvim_buf_set_lines(menu.buf, 0, -1, false, lines)

    local kind_hl = menu_hl("BlinkCmpKindText", menu_hl("BlinkCmpKind", "PmenuKind"))
    local label_hl = menu_hl("BlinkCmpLabel", "Pmenu")
    local match_hl = menu_hl("BlinkCmpLabelMatch", "Special")
    local desc_hl = menu_hl("BlinkCmpLabelDescription", "PmenuExtra")

    for i, it in ipairs(menu.items) do
      local p = parts[i]

      vim.api.nvim_buf_set_extmark(menu.buf, MENU_NS, i - 1, 1, { end_col = 1 + #MENU_ICON, hl_group = kind_hl })

      vim.api.nvim_buf_set_extmark(
        menu.buf,
        MENU_NS,
        i - 1,
        #prefix,
        { end_col = #prefix + #p.word, hl_group = label_hl }
      )

      if it.mstart and it.mstart <= #p.word then
        vim.api.nvim_buf_set_extmark(menu.buf, MENU_NS, i - 1, #prefix + it.mstart - 1, {
          end_col = #prefix + math.min(it.mend, #p.word),
          hl_group = match_hl,
          priority = 200,
        })
      end

      if p.desc ~= "" then
        vim.api.nvim_buf_set_extmark(
          menu.buf,
          MENU_NS,
          i - 1,
          #prefix + #p.word + 1,
          { end_col = #lines[i] - 1, hl_group = desc_hl }
        )
      end
    end

    -- selected row: explicit line highlight (cursorline is not drawn in non-current windows)
    vim.wo[menu.win].cursorline = false

    if menu.sel > 0 then
      vim.api.nvim_buf_set_extmark(
        menu.buf,
        MENU_NS,
        menu.sel - 1,
        0,
        { line_hl_group = "UtilsFormMenuSel", priority = 100 }
      )
    end

    vim.api.nvim_win_set_cursor(menu.win, { math.max(menu.sel, 1), 0 })
  end

  local function menu_show(row, line, start, matches, sel)
    if #matches == 0 then
      menu_close()
      return
    end

    menu.items = matches
    menu.start = start
    menu.row = row
    menu.sel = sel or 1 -- first entry preselected
    menu.engaged = false -- first <Tab> selects entry 1 instead of moving to 2

    local w = 15 -- blink min_width

    for _, it in ipairs(matches) do
      local ww = 1 + vim.fn.strdisplaywidth(MENU_ICON) + 2 + vim.fn.strdisplaywidth(it.word) + 1

      if it.menu and it.menu ~= "" then
        ww = ww + 1 + vim.fn.strdisplaywidth(it.menu)
      end

      w = math.max(w, ww)
    end

    w = math.min(w, 80, vim.o.columns - 4)
    menu.width = w

    local h = math.min(#matches, 10)
    local wp = vim.fn.win_screenpos(win)
    local sp = vim.fn.screenpos(win, row, 1)
    local cursor_row = sp.row > 0 and sp.row or (wp[1] + (row - 1) * 2) -- 1-based screen row of cursor line
    local label_off = 1 + vim.fn.strdisplaywidth(MENU_ICON) + 2
    local text_col = (wp[2] - 1) + text_off + vim.fn.strdisplaywidth(line:sub(1, start - 1))
    local col0 = text_col - label_off - 1 -- align label with the typed text (1 for the border)
    local row0 = cursor_row -- 0-based row == the line below the cursor (top border sits there)

    if row0 + h + 2 > vim.o.lines - 1 then
      row0 = math.max(cursor_row - 1 - h - 2, 0)
    end

    col0 = math.max(math.min(col0, vim.o.columns - w - 2), 0)

    if not (menu.buf and vim.api.nvim_buf_is_valid(menu.buf)) then
      menu.buf = vim.api.nvim_create_buf(false, true)
      vim.bo[menu.buf].bufhidden = "wipe"
    end

    local cfg = { relative = "editor", row = row0, col = col0, width = w, height = h }

    if menu_open() then
      vim.api.nvim_win_set_config(menu.win, cfg)
    else
      menu.win = vim.api.nvim_open_win(
        menu.buf,
        false,
        vim.tbl_extend("force", cfg, { style = "minimal", border = "rounded", focusable = false, zindex = 200, noautocmd = true })
      )

      local m = menu_hl("BlinkCmpMenu", "Pmenu")
      local ok, colors = pcall(require, "config.color")
      local pmenu = vim.api.nvim_get_hl(0, { name = m, link = false })

      -- blue rounded border, gray selected row
      vim.api.nvim_set_hl(0, "UtilsFormMenuBorder", { fg = ok and colors.blue or nil, bg = pmenu.bg })
      vim.api.nvim_set_hl(0, "UtilsFormMenuSel", { bg = ok and colors.dark_gray or nil })

      vim.wo[menu.win].wrap = false
      vim.wo[menu.win].winhighlight = string.format(
        "Normal:%s,NormalFloat:%s,EndOfBuffer:%s,FloatBorder:UtilsFormMenuBorder,CursorLine:UtilsFormMenuSel,Search:None",
        m,
        m,
        m
      )
    end

    menu_draw()
  end

  local function menu_move(step)
    if not menu_open() then
      return
    end

    local n = #menu.items

    if menu.engaged or step < 0 then
      menu.sel = menu.sel + step
    end

    menu.engaged = true

    if menu.sel < 1 then
      menu.sel = n -- prev from the top wraps to the bottom
    elseif menu.sel > n then
      menu.sel = 1 -- next from the bottom wraps to the top
    end

    menu_draw()

    -- auto insert: put the selected word in place of the typed token
    local row, col = unpack(vim.api.nvim_win_get_cursor(win))
    local line = vim.api.nvim_get_current_line()
    local word = menu.items[menu.sel].word
    local new = line:sub(1, menu.start - 1) .. word .. line:sub(col + 1)

    vim.api.nvim_set_current_line(new)
    vim.api.nvim_win_set_cursor(win, { row, menu.start - 1 + #word })
    snapshot = snapshot_text()
    render()
    notify_change()
  end

  -- completion menu of the field's items, filtered by what is typed (last segment for compact fields)
  local function show_completion(all)
    if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_get_current_win() ~= win then
      return
    end

    if not vim.fn.mode():match("^i") then
      return
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(win))
    local f = fields[row]

    if not f or not f.items then
      return
    end

    local function present(list)
      if not vim.api.nvim_win_is_valid(win) or not vim.fn.mode():match("^i") then
        return
      end

      local r, c = unpack(vim.api.nvim_win_get_cursor(win))

      if r ~= row then
        return
      end

      local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""
      local before = line:sub(1, c)
      local start = f.compact and (before:match(".*,()") or 1) or 1
      local current = before:sub(start)
      local token = all and "" or current:lower()

      if not all and current == "" then
        menu_close() -- typed menus need at least one character; <Tab> opens the full list
        return
      end
      local chosen = {}

      if f.compact then
        for part in line:gmatch("[^,]+") do
          chosen[vim.trim(part)] = true
        end
      end

      local matches = {}

      for _, it in ipairs(form_normalize_items(list)) do
        local lw = it.word:lower()

        if lw ~= token and not chosen[it.word] and (token == "" or lw:find(token, 1, true)) then
          local ms, me
          if token ~= "" then
            ms, me = lw:find(token, 1, true)
          end

          table.insert(matches, { word = it.word, menu = it.menu, mstart = ms, mend = me })
        end
      end

      menu_show(row, line, start, matches, 1) -- first entry preselected
    end

    if type(f.items) == "function" then
      f.items(vim.schedule_wrap(present), parse())
    else
      present(f.items)
    end
  end

  local goto_row, field_cycle, submit

  goto_row = function(row)
    menu_close()

    if not vim.api.nvim_win_is_valid(win) then
      return
    end

    row = math.min(row, vim.api.nvim_buf_line_count(buf))

    local text = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""

    vim.api.nvim_win_set_cursor(win, { row, #text })
    vim.cmd("startinsert!")
  end

  field_cycle = function(step)
    menu_close()
    local row = vim.api.nvim_win_get_cursor(win)[1]
    local order = {}

    for i = 1, nf do
      table.insert(order, i)
    end

    if has_body then
      table.insert(order, body_row)
    end

    local idx = 1

    for i, r in ipairs(order) do
      if row >= r then
        idx = i
      end
    end

    goto_row(order[(idx - 1 + step) % #order + 1])
  end

  goto_row(opts.start_row or 1)

  if opts.on_change then
    vim.schedule(notify_change) -- initial state (e.g. highlight for prefilled values)
  end


  local group = vim.api.nvim_create_augroup("UtilsForm" .. buf, { clear = true })

  vim.api.nvim_create_autocmd("TextChangedI", {
    group = group,
    buffer = buf,
    callback = function()
      local now = snapshot_text()

      if now == snapshot then
        return
      end

      snapshot = now

      vim.schedule(function()
        render()
        show_completion()

        notify_change()
      end)
    end,
  })

  vim.api.nvim_create_autocmd("TextChanged", {
    group = group,
    buffer = buf,
    callback = function()
      vim.schedule(render)
    end,
  })

  vim.api.nvim_create_autocmd("WinResized", { group = group, callback = vim.schedule_wrap(render) })
  vim.api.nvim_create_autocmd("InsertLeave", { group = group, buffer = buf, callback = menu_close })

  -- keeps the cursor off the divider row; also drops a menu whose row the cursor left (arrows, mouse, ...)
  local last_row = opts.start_row or 1
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    buffer = buf,
    callback = function()
      local r = vim.api.nvim_win_get_cursor(win)[1]

      if has_body and r == sep_row then
        -- skip the divider row (moving down -> body, moving up -> last field)
        r = last_row <= nf and body_row or nf
        vim.api.nvim_win_set_cursor(win, { r, #(vim.api.nvim_buf_get_lines(buf, r - 1, r, false)[1] or "") })
      end

      last_row = r

      if menu_open() and r ~= menu.row then
        menu_close()
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = buf,
    callback = function()
      menu_close()

      if opts.on_close then
        opts.on_close()
      end

      pcall(vim.api.nvim_del_augroup_by_id, group) -- drops the global WinResized autocmd too
    end,
  })

  local function close()
    menu_close()
    vim.cmd("stopinsert")

    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  submit = function()
    local data = parse()

    for i, f in ipairs(fields) do
      if f.required and data[f.key] == "" then
        vim.notify(f.label .. " is required", vim.log.levels.WARN, { title = opts.notify_title })
        goto_row(i)
        return
      end
    end

    close()
    vim.schedule(function()
      opts.on_submit(data)
    end)
  end

  local map_opts = { buffer = buf, nowait = true, silent = true }

  -- field rows are fixed lines: never let <BS>/<Del>/dd join or remove them (would shift values between fields)
  local function guarded(key, fallback, joins_next)
    vim.keymap.set("i", key, function()
      local pos = vim.api.nvim_win_get_cursor(win)
      local row, col = pos[1], pos[2]
      local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""
      local locked = row <= nf or (has_body and row <= body_row)

      if locked and ((not joins_next and col == 0) or (joins_next and col >= #line)) then
        return ""
      end

      return vim.api.nvim_replace_termcodes(fallback, true, false, true)
    end, vim.tbl_extend("force", map_opts, { expr = true, replace_keycodes = false }))
  end

  guarded("<BS>", "<BS>")
  guarded("<C-h>", "<C-h>")
  guarded("<C-w>", "<C-w>")
  guarded("<C-u>", "<C-u>")
  guarded("<Del>", "<Del>", true)

  vim.keymap.set("n", "dd", function()
    local row = vim.api.nvim_win_get_cursor(win)[1]

    if row <= nf or (has_body and row <= body_row) then
      vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { "" }) -- clear, keep the line
    else
      vim.cmd("normal! dd")
    end
  end, map_opts)


  vim.keymap.set({ "n", "i" }, "<C-CR>", submit, map_opts)
  vim.keymap.set("n", "q", close, map_opts)

  vim.keymap.set({ "n", "i" }, "<C-n>", function()
    field_cycle(1)
  end, map_opts)

  vim.keymap.set({ "n", "i" }, "<C-e>", function()
    field_cycle(-1)
  end, map_opts)

  vim.keymap.set({ "n", "i" }, "<S-CR>", function()
    field_cycle(-1)
  end, map_opts)

  -- <Tab>/<S-Tab>: walk the completion menu (open it first when closed)
  vim.keymap.set("i", "<Tab>", function()
    if menu_open() then
      menu_move(1)
    else
      show_completion(true)
    end
  end, map_opts)

  vim.keymap.set("i", "<S-Tab>", function()
    menu_move(-1)
  end, map_opts)

  vim.keymap.set("i", "<CR>", function()
    local row = vim.api.nvim_win_get_cursor(win)[1]
    local f = fields[row]

    if menu_open() and menu.sel > 0 then
      -- accept the highlighted entry, then continue
      local item = menu.items[menu.sel]
      local col = vim.api.nvim_win_get_cursor(win)[2]
      local line = vim.api.nvim_get_current_line()
      local new = line:sub(1, menu.start - 1) .. item.word

      menu_close()

      if f and f.compact then
        new = new .. ","
      end

      vim.api.nvim_set_current_line(new .. line:sub(col + 1))
      vim.api.nvim_win_set_cursor(win, { row, #new })
      snapshot = snapshot_text()
      render()
      notify_change()

      if f and f.compact then
        show_completion()
      elseif row < nf or has_body then
        field_cycle(1)
      end

      return
    end

    menu_close()

    if row < nf or (row == nf and has_body) then
      field_cycle(1)
    elseif row == nf then
      submit()
    elseif has_body and row == sep_row then
      field_cycle(1) -- divider row takes no input
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
    end
  end, map_opts)
end

return M
