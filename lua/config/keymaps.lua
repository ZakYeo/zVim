vim.keymap.set({ "n", "v", "o" }, "<Space>", "<Nop>", { silent = true })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window: move left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window: move down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window: move up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window: move right" })

vim.keymap.set("n", "<leader>w", "<Cmd>write<CR>", { desc = "File: write" })

vim.keymap.set("n", "<leader>lc", function()
  vim.cmd.edit(vim.fn.expand("$MYVIMRC"))
end, { desc = "Config: open init.lua" })
