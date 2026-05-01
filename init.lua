vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.highlights").setup()
require("config.smooth_scroll_setup")
require("config.lsp")
require("config.lazy")
