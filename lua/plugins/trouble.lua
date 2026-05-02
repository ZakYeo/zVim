return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    {
      "<leader>xx",
      "<Cmd>Trouble diagnostics toggle<CR>",
      desc = "Trouble: diagnostics",
    },
    {
      "<leader>xX",
      "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>",
      desc = "Trouble: buffer diagnostics",
    },
    {
      "<leader>cs",
      "<Cmd>Trouble symbols toggle focus=false<CR>",
      desc = "Trouble: document symbols",
    },
    {
      "<leader>cl",
      "<Cmd>Trouble lsp toggle focus=false win.position=right<CR>",
      desc = "Trouble: LSP locations",
    },
    {
      "<leader>xL",
      "<Cmd>Trouble loclist toggle<CR>",
      desc = "Trouble: location list",
    },
    {
      "<leader>xQ",
      "<Cmd>Trouble qflist toggle<CR>",
      desc = "Trouble: quickfix list",
    },
  },
  opts = {},
}
