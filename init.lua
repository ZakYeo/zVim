-- ~/.config/nvim-stable/init.lua

-- Leader key (set before plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Stop <Space> from doing its normal-mode default (move right)
vim.keymap.set({ "n", "v", "o" }, "<Space>", "<Nop>", { silent = true })


-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.keymap.set("n", "<leader>lc", function()
  vim.cmd.edit(vim.fn.expand("$MYVIMRC"))
end, { desc = "Config: open init.lua" })


vim.o.timeout = true
vim.o.timeoutlen = 300
vim.o.showtabline = 2
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.termguicolors = true
vim.opt.rtp:prepend(lazypath)

local function use_terminal_background()
  local transparent_groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "SignColumn",
    "EndOfBuffer",
    "TabLineFill",
    "BufferLineFill",
    "NeoTreeNormal",
    "NeoTreeNormalNC",
    "WhichKeyFloat",
    "Pmenu",
  }

  for _, group in ipairs(transparent_groups) do
    vim.cmd.highlight(group .. " guibg=NONE ctermbg=NONE")
  end
end

use_terminal_background()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = use_terminal_background,
})

require("config.smooth_scroll").setup({
  duration = 190,
  fps = 60,
  easing = "out_sine",
  mappings = {
    default_control = true,
    jk = false,
    mouse = false,
  },
})

local function neo_tree_width()
  return math.max(math.floor(vim.o.columns * 0.25), 30)
end

local function resize_neo_tree()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      vim.api.nvim_win_set_width(win, neo_tree_width())
    end
  end
end

local function open_neo_tree(opts)
  require("neo-tree.command").execute(vim.tbl_extend("force", {
    source = "filesystem",
    position = "right",
  }, opts or {}))
  vim.schedule(resize_neo_tree)
end

vim.keymap.set("n", "<leader>e", function()
  open_neo_tree({ toggle = true, reveal = true })
end, { desc = "Explorer: toggle" })

vim.keymap.set("n", "<leader>E", function()
  open_neo_tree({ action = "focus", dir = vim.fn.getcwd() })
end, { desc = "Explorer: cwd" })

vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
  callback = resize_neo_tree,
})

require("lazy").setup({
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>e", desc = "Explorer: toggle" },
        { "<leader>E", desc = "Explorer: cwd" },
        { "<leader>0", desc = "Buffer: last tab" },
        { "<leader>1", desc = "Buffer: tab 1" },
        { "<leader>2", desc = "Buffer: tab 2" },
        { "<leader>3", desc = "Buffer: tab 3" },
        { "<leader>4", desc = "Buffer: tab 4" },
        { "<leader>5", desc = "Buffer: tab 5" },
        { "<leader>6", desc = "Buffer: tab 6" },
        { "<leader>7", desc = "Buffer: tab 7" },
        { "<leader>8", desc = "Buffer: tab 8" },
        { "<leader>9", desc = "Buffer: tab 9" },
        { "<leader>b", group = "buffer" },
        { "<leader>bd", desc = "Buffer: close" },
        { "<leader>l", group = "lua/config" },
        { "<leader>lc", desc = "Config: open init.lua" },
        { "<S-h>", desc = "Buffer: previous tab" },
        { "<S-l>", desc = "Buffer: next tab" },
      },
    },
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
      local bufferline = require("bufferline")

      bufferline.setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          indicator = {
            style = "underline",
          },
          modified_icon = "●",
          show_buffer_close_icons = false,
          show_close_icon = false,
          show_tab_indicators = true,
          separator_style = "thin",
          always_show_bufferline = true,
          offsets = {
            {
              filetype = "neo-tree",
              text = "Explorer",
              text_align = "center",
              separator = true,
            },
          },
        },
      })
      use_terminal_background()

      vim.keymap.set("n", "<S-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Buffer: next tab" })
      vim.keymap.set("n", "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Buffer: previous tab" })
      vim.keymap.set("n", "<leader>0", "<Cmd>BufferLineGoToBuffer -1<CR>", { desc = "Buffer: last tab" })
      vim.keymap.set("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Buffer: close" })

      for i = 1, 9 do
        vim.keymap.set("n", "<leader>" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", {
          desc = "Buffer: tab " .. i,
        })
      end
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        enable_diagnostics = true,
        enable_git_status = true,
        filesystem = {
          bind_to_cwd = true,
          follow_current_file = {
            enabled = true,
          },
          filtered_items = {
            hide_dotfiles = true,
            hide_gitignored = true,
          },
          hijack_netrw_behavior = "open_default",
          use_libuv_file_watcher = true,
        },
        window = {
          position = "right",
          width = neo_tree_width(),
        },
      })
    end,
  },
})
