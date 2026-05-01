local M = {}

function M.use_terminal_background()
  local transparent_groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "SignColumn",
    "EndOfBuffer",
    "TabLineFill",
    "BufferLineFill",
    "NeoTreeNormal",
    "NeoTreeNormalNC",
    "WhichKeyFloat",
    "Pmenu",
  }

  for _, group in ipairs(transparent_groups) do
    vim.cmd.highlight(group .. " guibg=NONE ctermbg=NONE")
  end
end

function M.setup()
  M.use_terminal_background()

  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = M.use_terminal_background,
  })
end

return M
