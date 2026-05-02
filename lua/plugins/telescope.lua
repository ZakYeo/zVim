return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  lazy = false,
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            preview_width = 0.55,
            preview_cutoff = 80,
            prompt_position = "top",
          },
        },
        sorting_strategy = "ascending",
        mappings = {
          i = {
            ["<C-t>"] = function(...)
              return require("trouble.sources.telescope").open(...)
            end,
            ["<C-a>"] = function(...)
              return require("trouble.sources.telescope").add(...)
            end,
          },
          n = {
            ["<C-t>"] = function(...)
              return require("trouble.sources.telescope").open(...)
            end,
            ["<C-a>"] = function(...)
              return require("trouble.sources.telescope").add(...)
            end,
          },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })

    telescope.load_extension("fzf")

    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find: files" })
    vim.keymap.set("n", "<leader>fw", builtin.live_grep, { desc = "Find: word search" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find: buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find: help" })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Find: recent files" })
    vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Find: commands" })
    vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find: diagnostics" })
  end,
}
