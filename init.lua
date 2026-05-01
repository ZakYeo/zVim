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
vim.opt.rtp:prepend(lazypath)

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
        { "<leader>l", group = "lua/config" },
        { "<leader>lc", desc = "Config: open init.lua" },
      },
    },
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
