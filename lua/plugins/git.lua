return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "_" },
        changedelete = { text = "~" },
        untracked = { text = "+" },
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, {
            buffer = bufnr,
            desc = desc,
            silent = true,
          })
        end

        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, "Git: next hunk")

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, "Git: previous hunk")

        map("n", "<leader>gs", gitsigns.stage_hunk, "Git: stage hunk")
        map("n", "<leader>gr", gitsigns.reset_hunk, "Git: reset hunk")
        map("v", "<leader>gs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Git: stage hunk")
        map("v", "<leader>gr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Git: reset hunk")
        map("n", "<leader>gS", gitsigns.stage_buffer, "Git: stage buffer")
        map("n", "<leader>gR", gitsigns.reset_buffer, "Git: reset buffer")
        map("n", "<leader>gp", gitsigns.preview_hunk, "Git: preview hunk")
        map("n", "<leader>gb", function()
          gitsigns.blame_line({ full = true })
        end, "Git: blame line")
        map("n", "<leader>gd", gitsigns.diffthis, "Git: diff file")
        map("n", "<leader>gq", gitsigns.setqflist, "Git: hunks to quickfix")
        map({ "o", "x" }, "ih", gitsigns.select_hunk, "Git: select hunk")
      end,
    },
  },
}
