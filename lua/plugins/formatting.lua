local prettier_config_files = {
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.json5",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  ".prettierrc.ts",
  ".prettierrc.cts",
  ".prettierrc.mts",
  ".prettierrc.toml",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
  "prettier.config.ts",
  "prettier.config.cts",
  "prettier.config.mts",
}

local function package_has_prettier(path)
  local package_json = vim.fs.joinpath(path, "package.json")
  local ok, contents = pcall(vim.fn.readfile, package_json)
  if not ok then
    return false
  end

  local ok_decode, package_data = pcall(vim.json.decode, table.concat(contents, "\n"))
  return ok_decode and package_data and package_data.prettier ~= nil
end

local function prettier_root(_, ctx)
  return vim.fs.root(ctx.dirname, function(name, path)
    if vim.tbl_contains(prettier_config_files, name) then
      return true
    end

    return name == "package.json" and package_has_prettier(path)
  end)
end

return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = {
      ensure_installed = {
        "stylua",
        "prettier",
        "shfmt",
        "markdownlint-cli2",
      },
      auto_update = false,
      run_on_start = true,
      start_delay = 3000,
      debounce_hours = 12,
    },
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier", stop_after_first = true },
        javascriptreact = { "prettier", stop_after_first = true },
        typescript = { "prettier", stop_after_first = true },
        typescriptreact = { "prettier", stop_after_first = true },
        json = { "prettier", stop_after_first = true },
        html = { "prettier", stop_after_first = true },
        css = { "prettier", stop_after_first = true },
        markdown = { "prettier", "markdownlint-cli2" },
        yaml = { "prettier", stop_after_first = true },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
      formatters = {
        prettier = {
          cwd = prettier_root,
        },
        shfmt = {
          append_args = { "-i", "2" },
        },
      },
    },
  },
}
