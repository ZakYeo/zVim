return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  lazy = false,
  config = function()
    local explorer = require("config.explorer")

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
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_ignored = false,
          hide_hidden = false,
          hide_by_name = {},
          hide_by_pattern = {},
          never_show = {},
          never_show_by_pattern = {},
        },
        hijack_netrw_behavior = "open_default",
        use_libuv_file_watcher = true,
      },
      window = {
        position = "right",
        width = explorer.neo_tree_width(),
      },
    })

    explorer.setup_keymaps()
    explorer.setup_autocmds()
  end,
}
