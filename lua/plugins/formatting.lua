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
        shfmt = {
          append_args = { "-i", "2" },
        },
      },
    },
  },
}
