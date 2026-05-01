vim.keymap.set({ "n", "v", "o" }, "<Space>", "<Nop>", { silent = true })

vim.keymap.set("n", "<leader>lc", function()
  vim.cmd.edit(vim.fn.expand("$MYVIMRC"))
end, { desc = "Config: open init.lua" })
