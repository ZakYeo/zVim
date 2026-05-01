local treesitter_languages = {
  "lua",
  "luadoc",
  "vim",
  "vimdoc",
  "query",
  "javascript",
  "typescript",
  "tsx",
  "json",
  "html",
  "css",
  "markdown",
  "markdown_inline",
  "bash",
  "yaml",
  "toml",
}

local treesitter_filetypes = {
  "lua",
  "luadoc",
  "vim",
  "vimdoc",
  "query",
  "javascript",
  "typescript",
  "typescriptreact",
  "json",
  "html",
  "css",
  "markdown",
  "bash",
  "sh",
  "yaml",
  "toml",
}

local function has_attached_ui()
  return #vim.api.nvim_list_uis() > 0
end

local function first_line(value)
  return vim.split(vim.trim(value or ""), "\n", { plain = true })[1] or ""
end

local function install_treesitter_parsers()
  if not has_attached_ui() then
    return
  end

  vim.system({ "tree-sitter", "--version" }, { text = true }, function(result)
    vim.schedule(function()
      if not has_attached_ui() then
        return
      end

      if result.code ~= 0 then
        local output = result.stderr and result.stderr ~= "" and result.stderr or result.stdout
        local reason = first_line(output)
        vim.notify(
          "Skipping Treesitter parser install: tree-sitter CLI is not usable. " .. reason,
          vim.log.levels.WARN
        )
        return
      end

      local ok, treesitter = pcall(require, "nvim-treesitter")

      if ok then
        treesitter.install(treesitter_languages)
      end
    end)
  end)
end

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  config = function()
    require("nvim-treesitter").setup()
    install_treesitter_parsers()

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
      pattern = treesitter_filetypes,
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
