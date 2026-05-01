local M = {}

local uv = vim.uv or vim.loop

local defaults = {
  duration = 190,
  fps = 60,
  easing = "out_sine",
  mappings = {
    default_control = true,
    jk = false,
    mouse = false,
  },
}

local easings = {
  linear = function(t)
    return t
  end,
  sine = function(t)
    return -(math.cos(math.pi * t) - 1) / 2
  end,
  out_sine = function(t)
    return math.sin((t * math.pi) / 2)
  end,
  quad = function(t)
    return t * t
  end,
  cubic = function(t)
    return t * t * t
  end,
}

local states = {}
local mapped_lhs = {}
local options = vim.deepcopy(defaults)

local function close_timer(timer)
  if timer and not timer:is_closing() then
    timer:stop()
    timer:close()
  end
end

local function cancel_win(win)
  if states[win] then
    close_timer(states[win].timer)
  end

  states[win] = nil
end

local function round(value)
  if value >= 0 then
    return math.floor(value + 0.5)
  end

  return math.ceil(value - 0.5)
end

local function interpolate(start_value, target_value, progress)
  return start_value + round((target_value - start_value) * progress)
end

local function normal_keys(keys, count)
  local prefix = count and count > 0 and tostring(count) or ""
  local termcoded = vim.api.nvim_replace_termcodes(prefix .. keys, true, false, true)
  vim.api.nvim_feedkeys(termcoded, "nx", false)
end

local function win_view(win)
  return vim.api.nvim_win_call(win, vim.fn.winsaveview)
end

local function restore_view(win, view)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  vim.api.nvim_win_call(win, function()
    vim.fn.winrestview(view)
  end)
end

local function animate(win, start_view, target_view)
  local topline_distance = target_view.topline - start_view.topline
  local cursor_distance = target_view.lnum - start_view.lnum

  cancel_win(win)

  if topline_distance == 0 and cursor_distance == 0 then
    restore_view(win, target_view)
    return
  end

  local easing = easings[options.easing] or easings.sine
  local duration = math.max(options.duration, 1)
  local interval = math.max(math.floor(1000 / math.max(options.fps, 1)), 1)
  local frames = math.max(math.ceil(duration / interval), 1)
  local frame = 0
  local timer = uv.new_timer()

  states[win] = {
    timer = timer,
    target_view = target_view,
  }

  timer:start(0, interval, vim.schedule_wrap(function()
    if not vim.api.nvim_win_is_valid(win) or not states[win] or states[win].timer ~= timer then
      if states[win] and states[win].timer == timer then
        states[win] = nil
      end

      close_timer(timer)
      return
    end

    frame = frame + 1

    if frame >= frames then
      restore_view(win, target_view)
      cancel_win(win)
      return
    end

    local progress = easing(frame / frames)
    local view = vim.deepcopy(target_view)
    view.topline = interpolate(start_view.topline, target_view.topline, progress)
    view.lnum = interpolate(start_view.lnum, target_view.lnum, progress)
    restore_view(win, view)
  end))
end

function M.cancel()
  local win = vim.api.nvim_get_current_win()
  cancel_win(win)
end

function M.scroll(keys)
  local win = vim.api.nvim_get_current_win()
  local count = vim.v.count
  local pending_view = states[win] and states[win].target_view or nil
  local start_view = win_view(win)

  if pending_view then
    restore_view(win, pending_view)
  end

  normal_keys(keys, count)

  if not vim.api.nvim_win_is_valid(win) then
    cancel_win(win)
    return
  end

  local target_view = win_view(win)
  restore_view(win, start_view)
  animate(win, start_view, target_view)
end

local function map_scroll(lhs, rhs, desc)
  mapped_lhs[lhs] = true
  vim.keymap.set("n", lhs, function()
    M.scroll(rhs)
  end, {
    desc = desc,
    silent = true,
  })
end

local function clear_mappings()
  for lhs in pairs(mapped_lhs) do
    pcall(vim.keymap.del, "n", lhs)
  end

  mapped_lhs = {}
end

local function setup_mappings()
  clear_mappings()

  local mappings = options.mappings

  if mappings.default_control then
    map_scroll("<C-d>", "<C-d>", "Smooth scroll: half page down")
    map_scroll("<C-u>", "<C-u>", "Smooth scroll: half page up")
    map_scroll("<C-f>", "<C-f>", "Smooth scroll: page down")
    map_scroll("<C-b>", "<C-b>", "Smooth scroll: page up")
    map_scroll("<C-e>", "<C-e>", "Smooth scroll: line down")
    map_scroll("<C-y>", "<C-y>", "Smooth scroll: line up")
  end

  if mappings.jk then
    map_scroll("j", "j", "Smooth scroll: down")
    map_scroll("k", "k", "Smooth scroll: up")
  end

  if mappings.mouse then
    map_scroll("<ScrollWheelDown>", "<ScrollWheelDown>", "Smooth scroll: mouse down")
    map_scroll("<ScrollWheelUp>", "<ScrollWheelUp>", "Smooth scroll: mouse up")
  end
end

function M.setup(opts)
  options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  setup_mappings()
end

return M
