local ns = vim.api.nvim_create_namespace("scroll_indicator")

local function mark_line(buf, line)
  vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, {
    sign_text = "",
    sign_hl_group = "ScrollIndicator",
  })
end

local function mark_scroll()
  if vim.wo.signcolumn == "no" then
    return
  end

  local buf = 0
  local scroll_size = vim.wo.scroll

  if scroll_size == 0 then
    scroll_size = math.floor(vim.api.nvim_win_get_height(0) / 2)
  end

  -- clear previous marks
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  local current = vim.fn.line(".")
  local total_lines = vim.fn.line("$")
  local win_height = vim.api.nvim_win_get_height(0)

  -- Mark current position
  mark_line(buf, current)

  -- Mark positions above (scroll_up targets)
  local line = current - scroll_size

  if line < 1 then
    if current > 1 then
      mark_line(buf, 1)
    end
  else
    local count = 0
    while line >= 1 and count < win_height do
      mark_line(buf, line)
      line = line - scroll_size
      count = count + 1
    end
  end

  -- Mutark positions below (scroll_down targets)
  line = current + scroll_size

  if line > total_lines then
    if current < total_lines then
      mark_line(buf, total_lines)
    end
  else
    local count = 0
    while line <= total_lines and count < win_height do
      mark_line(buf, line)
      line = line + scroll_size
      count = count + 1
    end
  end
end

local function scroll_down()
  local key = vim.api.nvim_replace_termcodes("<C-d>", true, false, true)
  vim.api.nvim_feedkeys(key, "n", false)
  vim.schedule(mark_scroll)
end

local function scroll_up()
  local key = vim.api.nvim_replace_termcodes("<C-u>", true, false, true)
  vim.api.nvim_feedkeys(key, "n", false)
  vim.schedule(mark_scroll)
end

return {
  ns = ns,
  mark_scroll = mark_scroll,
  scroll_down = scroll_down,
  scroll_up = scroll_up,
}
