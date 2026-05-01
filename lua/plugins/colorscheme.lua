return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      transparent_background = true,
      integrations = {
        bufferline = true,
        mason = true,
        neotree = true,
        which_key = true,
      },
    })

    vim.cmd.colorscheme("catppuccin")
  end,
}
