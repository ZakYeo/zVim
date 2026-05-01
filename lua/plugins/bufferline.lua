return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  lazy = false,
  config = function()
    local bufferline = require("bufferline")
    local terminal = require("config.terminal")

    bufferline.setup({
      highlights = require("catppuccin.special.bufferline").get_theme(),
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
    require("config.highlights").use_terminal_background()

    vim.keymap.set("n", "<S-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Buffer: next tab" })
    vim.keymap.set("n", "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Buffer: previous tab" })
    vim.keymap.set("n", "<leader>b0", "<Cmd>BufferLineGoToBuffer -1<CR>", { desc = "Buffer: last tab" })
    vim.keymap.set("n", "<leader>bd", terminal.close_current_buffer, { desc = "Buffer: close" })

    for i = 1, 9 do
      vim.keymap.set("n", "<leader>b" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", {
        desc = "Buffer: tab " .. i,
      })
    end
  end,
}
