local M = {}

local lazygit

local function fullscreen_float_opts()
  return {
    border = "none",
    width = function()
      return vim.o.columns
    end,
    height = function()
      return vim.o.lines - vim.o.cmdheight
    end,
    row = 0,
    col = 0,
  }
end

local function lazygit_terminal()
  if not lazygit then
    local Terminal = require("toggleterm.terminal").Terminal

    lazygit = Terminal:new({
      cmd = "lazygit",
      direction = "float",
      hidden = true,
      float_opts = fullscreen_float_opts(),
    })
  end

  return lazygit
end

function M.open_terminal_buffer()
  local current_win = vim.api.nvim_get_current_win()
  local target_win
  local fallback_win
  local toggleterm_wins = {}

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)

    if vim.bo[buf].filetype == "toggleterm" then
      table.insert(toggleterm_wins, win)
    else
      fallback_win = fallback_win or win

      if vim.bo[buf].filetype ~= "neo-tree" then
        if win == current_win then
          target_win = win
        else
          target_win = target_win or win
        end
      end
    end
  end

  if not target_win then
    target_win = fallback_win
  end

  if target_win and vim.api.nvim_win_is_valid(target_win) then
    vim.api.nvim_set_current_win(target_win)

    for _, win in ipairs(toggleterm_wins) do
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  else
    for _, win in ipairs(toggleterm_wins) do
      if win ~= current_win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  end

  if vim.bo.filetype == "neo-tree" then
    vim.cmd.wincmd("p")
  end

  vim.cmd.enew()
  vim.bo.buflisted = true
  vim.cmd.terminal()
  vim.cmd.startinsert()
end

function M.toggle_lazygit()
  lazygit_terminal():toggle()
end

function M.toggle_bottom_terminal()
  local count = vim.v.count

  if count > 0 then
    require("toggleterm").toggle(count, nil, nil, "horizontal")
  else
    require("toggleterm").toggle(nil, nil, nil, "horizontal")
  end
end

function M.open_next_bottom_terminal()
  local next_id = 1

  for _, term in ipairs(require("toggleterm.terminal").get_all(true)) do
    next_id = math.max(next_id, term.id + 1)
  end

  require("toggleterm").toggle(next_id, nil, nil, "horizontal")
end

function M.cycle_buffer_tabs(step)
  local command = step > 0 and "BufferLineCycleNext" or "BufferLineCyclePrev"

  if pcall(vim.cmd, command) then
    return
  end

  if step > 0 then
    vim.cmd.bnext()
  else
    vim.cmd.bprevious()
  end
end

local function current_toggleterm_id()
  if vim.b.toggle_number then
    return vim.b.toggle_number
  end

  local id = vim.api.nvim_buf_get_name(0):match("#toggleterm#(%d+)")

  return id and tonumber(id) or nil
end

function M.cycle_terminal_tabs(step)
  local current_id = current_toggleterm_id()

  if not current_id then
    M.cycle_buffer_tabs(step)
    return
  end

  local terminal = require("toggleterm.terminal")
  local terminals = terminal.get_all()

  if #terminals < 2 then
    return
  end

  local current_index

  for index, term in ipairs(terminals) do
    if term.id == current_id then
      current_index = index
      break
    end
  end

  if not current_index then
    return
  end

  local target_index = ((current_index - 1 + step) % #terminals) + 1
  local target = terminals[target_index]
  local current_win = vim.api.nvim_get_current_win()

  if not target.bufnr or not vim.api.nvim_buf_is_valid(target.bufnr) then
    target:spawn()
  end

  vim.api.nvim_win_set_buf(current_win, target.bufnr)
end

function M.close_current_buffer()
  if vim.bo.buftype == "terminal" then
    vim.cmd.bdelete({ bang = true })
    return
  end

  vim.cmd.bdelete()
end

function M.setup_terminal_navigation()
  vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("user_terminal_keymaps", { clear = true }),
    pattern = "term://*",
    callback = function(event)
      local opts = {
        buffer = event.buf,
        silent = true,
      }

      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
      vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
      vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
      vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
      vim.keymap.set("n", "[b", function()
        M.cycle_terminal_tabs(-1)
      end, vim.tbl_extend("force", opts, { desc = "Terminal: previous tab" }))
      vim.keymap.set("n", "]b", function()
        M.cycle_terminal_tabs(1)
      end, vim.tbl_extend("force", opts, { desc = "Terminal: next tab" }))
      vim.keymap.set("t", "[b", function()
        vim.cmd.stopinsert()
        M.cycle_terminal_tabs(-1)
      end, vim.tbl_extend("force", opts, { desc = "Terminal: previous tab" }))
      vim.keymap.set("t", "]b", function()
        vim.cmd.stopinsert()
        M.cycle_terminal_tabs(1)
      end, vim.tbl_extend("force", opts, { desc = "Terminal: next tab" }))
    end,
  })
end

return M
