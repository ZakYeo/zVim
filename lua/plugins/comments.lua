return {
  {
    "folke/todo-comments.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TodoTelescope", "TodoQuickFix", "TodoLocList" },
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Todo: next comment",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Todo: previous comment",
      },
      {
        "<leader>ft",
        "<Cmd>TodoTelescope<CR>",
        desc = "Find: todo comments",
      },
      {
        "<leader>fT",
        "<Cmd>TodoTelescope keywords=TODO,FIX,FIXME<CR>",
        desc = "Find: todo/fix comments",
      },
    },
    opts = {},
  },
}
