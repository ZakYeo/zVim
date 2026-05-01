local M = {}

local function dashboard_header()
  local path = vim.fn.stdpath("config") .. "/title.txt"

  if vim.fn.filereadable(path) == 1 then
    return vim.fn.readfile(path)
  end

  return {
    "          zVim",
  }
end

function M.open()
  vim.cmd.Dashboard()
end

function M.setup()
  require("dashboard").setup({
    theme = "doom",
    config = {
      header = dashboard_header(),
      center = {
        {
          icon = "  ",
          desc = "Find files",
          key = "f",
          keymap = "SPC f f",
          key_format = " %s",
          action = "Telescope find_files",
        },
        {
          icon = "  ",
          desc = "Recent files",
          key = "r",
          keymap = "SPC f r",
          key_format = " %s",
          action = "Telescope oldfiles",
        },
        {
          icon = "󰱼  ",
          desc = "Search text",
          key = "w",
          keymap = "SPC f w",
          key_format = " %s",
          action = "Telescope live_grep",
        },
        {
          icon = "  ",
          desc = "Edit config",
          key = "c",
          keymap = "SPC l c",
          key_format = " %s",
          action = "edit $MYVIMRC",
        },
        {
          icon = "󰒲  ",
          desc = "Plugin manager",
          key = "l",
          key_format = " %s",
          action = "Lazy",
        },
        {
          icon = "󰚰  ",
          desc = "Sync plugins",
          key = "s",
          key_format = " %s",
          action = "Lazy sync",
        },
        {
          icon = "󰗼  ",
          desc = "Quit",
          key = "q",
          key_format = " %s",
          action = "qa",
        },
      },
      footer = {},
      vertical_center = true,
    },
  })

  vim.api.nvim_create_user_command("ZVimDashboard", M.open, {
    desc = "Open zVim dashboard",
  })

  vim.keymap.set("n", "<leader>h", M.open, {
    desc = "Dashboard: open",
  })
end

return M
