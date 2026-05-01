return {
  "akinsho/toggleterm.nvim",
  version = "*",
  lazy = false,
  config = function()
    local terminal = require("config.terminal")

    terminal.setup_terminal_navigation()

    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        end

        return math.floor(vim.o.columns * 0.4)
      end,
      direction = "horizontal",
      hide_numbers = true,
      shade_terminals = false,
      start_in_insert = true,
      persist_size = true,
      persist_mode = true,
      close_on_exit = true,
      auto_scroll = true,
      winbar = {
        enabled = true,
        name_formatter = function(term)
          return "terminal " .. term.id
        end,
      },
    })

    vim.keymap.set("n", "<leader>tt", terminal.toggle_bottom_terminal, {
      desc = "Terminal: toggle bottom",
    })
    vim.keymap.set("n", "<leader>tn", terminal.open_next_bottom_terminal, {
      desc = "Terminal: new bottom split",
    })
    vim.keymap.set("n", "<leader>tc", terminal.close_current_buffer, {
      desc = "Terminal: close",
    })
    vim.keymap.set("t", "<leader>tc", [[<C-\><C-n><Cmd>bdelete!<CR>]], {
      desc = "Terminal: close",
    })
    vim.keymap.set("n", "<leader>tT", terminal.open_terminal_buffer, {
      desc = "Terminal: full buffer",
    })
    vim.keymap.set("n", "<leader>ts", "<Cmd>TermSelect<CR>", {
      desc = "Terminal: select",
    })
    vim.keymap.set("n", "<leader>gg", terminal.toggle_lazygit, {
      desc = "Git: lazygit",
    })
  end,
}
