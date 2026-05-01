local M = {}

function M.neo_tree_width()
  return math.max(math.floor(vim.o.columns * 0.25), 30)
end

function M.resize_neo_tree()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      vim.api.nvim_win_set_width(win, M.neo_tree_width())
    end
  end
end

function M.open_neo_tree(opts)
  require("neo-tree.command").execute(vim.tbl_extend("force", {
    source = "filesystem",
    position = "right",
  }, opts or {}))
  vim.schedule(M.resize_neo_tree)
end

function M.setup_keymaps()
  vim.keymap.set("n", "<leader>e", function()
    M.open_neo_tree({ toggle = true, reveal = true })
  end, { desc = "Explorer: toggle" })

  vim.keymap.set("n", "<leader>E", function()
    M.open_neo_tree({ action = "focus", dir = vim.fn.getcwd() })
  end, { desc = "Explorer: cwd" })
end

function M.setup_autocmds()
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    callback = M.resize_neo_tree,
  })
end

return M
