vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    source = "if_many",
    spacing = 4,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
})

vim.lsp.config("*", {
  capabilities = vim.tbl_deep_extend(
    "force",
    {
      textDocument = {
        semanticTokens = {
          multilineTokenSupport = true,
        },
      },
    },
    require("blink.cmp").get_lsp_capabilities(nil, true)
  ),
  root_markers = { ".git" },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_config", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local bufnr = event.buf

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = bufnr,
        desc = desc,
        silent = true,
      })
    end

    map("n", "gd", vim.lsp.buf.definition, "LSP: definition")
    map("n", "gD", vim.lsp.buf.declaration, "LSP: declaration")
    map("n", "gi", vim.lsp.buf.implementation, "LSP: implementation")
    map("n", "gr", vim.lsp.buf.references, "LSP: references")
    map("n", "K", vim.lsp.buf.hover, "LSP: hover")
    map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
    map("n", "<leader>lf", function()
      require("conform").format({
        async = true,
        bufnr = bufnr,
        lsp_format = "fallback",
      })
    end, "LSP: format")
    map("n", "<leader>ld", function()
      vim.diagnostic.open_float({ scope = "line" })
    end, "LSP: line diagnostic")
    map("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, "LSP: previous diagnostic")
    map("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, "LSP: next diagnostic")
  end,
})
