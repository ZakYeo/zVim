local eslint_config_files = {
  "eslint.config.js",
  "eslint.config.cjs",
  "eslint.config.mjs",
  "eslint.config.ts",
  "eslint.config.cts",
  "eslint.config.mts",
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  ".eslintrc.json",
}

local eslint_filetypes = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}

local function read_json_file(path)
  local ok, contents = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end

  local ok_decode, data = pcall(vim.json.decode, table.concat(contents, "\n"))
  if not ok_decode then
    return nil
  end

  return data
end

local function package_has_eslint_config(path)
  local package_data = read_json_file(vim.fs.joinpath(path, "package.json"))
  return package_data and package_data.eslintConfig ~= nil
end

local function eslint_root(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return nil
  end

  return vim.fs.root(vim.fs.dirname(filename), function(name, path)
    if vim.tbl_contains(eslint_config_files, name) then
      return true
    end

    return name == "package.json" and package_has_eslint_config(path)
  end)
end

local function eslint_command(root)
  local bin_name = vim.fn.has("win32") == 1 and "eslint.cmd" or "eslint"
  local command = vim.fs.joinpath(root, "node_modules", ".bin", bin_name)

  if vim.fn.executable(command) == 1 then
    return command
  end

  return nil
end

local function configure_eslint_linter(root, command)
  local lint = require("lint")
  local eslint = require("lint.linters.eslint")

  lint.linters.eslint_project = vim.tbl_extend("force", eslint, {
    cmd = command,
    cwd = root,
  })
end

local function try_eslint()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  if not eslint_filetypes[filetype] then
    return
  end

  local root = eslint_root(bufnr)
  if not root then
    return
  end

  local command = eslint_command(root)
  if not command then
    return
  end

  configure_eslint_linter(root, command)
  require("lint").try_lint("eslint_project")
end

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("user_lint_config", { clear = true }),
        callback = try_eslint,
      })

      vim.schedule(try_eslint)
    end,
  },
}
