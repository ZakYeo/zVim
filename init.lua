-- ~/.config/nvim-stable/init.lua

-- Leader key (set before plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Stop <Space> from doing its normal-mode default (move right)
vim.keymap.set({ "n", "v", "o" }, "<Space>", "<Nop>", { silent = true })


-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.keymap.set("n", "<leader>lc", function()
  vim.cmd.edit(vim.fn.expand("$MYVIMRC"))
end, { desc = "Config: open init.lua" })


vim.o.timeout = true
vim.o.timeoutlen = 300
vim.o.showtabline = 2
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
vim.opt.termguicolors = true
vim.opt.rtp:prepend(lazypath)

local function use_terminal_background()
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

use_terminal_background()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = use_terminal_background,
})

require("config.smooth_scroll").setup({
  duration = 190,
  fps = 60,
  easing = "out_sine",
  mappings = {
    default_control = true,
    jk = false,
    mouse = false,
  },
})

local function neo_tree_width()
  return math.max(math.floor(vim.o.columns * 0.25), 30)
end

local function resize_neo_tree()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      vim.api.nvim_win_set_width(win, neo_tree_width())
    end
  end
end

local function open_neo_tree(opts)
  require("neo-tree.command").execute(vim.tbl_extend("force", {
    source = "filesystem",
    position = "right",
  }, opts or {}))
  vim.schedule(resize_neo_tree)
end

local function open_terminal_buffer()
  local current_win = vim.api.nvim_get_current_win()
  local target_win
  local fallback_win
  local toggleterm_wins = {}

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)

    if vim.bo[buf].filetype == "toggleterm" then
      table.insert(toggleterm_wins, win)
    else
      fallback_win = fallback_win or win

      if vim.bo[buf].filetype ~= "neo-tree" then
        if win == current_win then
          target_win = win
        else
          target_win = target_win or win
        end
      end
    end
  end

  if not target_win then
    target_win = fallback_win
  end

  if target_win and vim.api.nvim_win_is_valid(target_win) then
    vim.api.nvim_set_current_win(target_win)

    for _, win in ipairs(toggleterm_wins) do
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  else
    for _, win in ipairs(toggleterm_wins) do
      if win ~= current_win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  end

  if vim.bo.filetype == "neo-tree" then
    vim.cmd.wincmd("p")
  end

  vim.cmd.enew()
  vim.bo.buflisted = true
  vim.cmd.terminal()
  vim.cmd.startinsert()
end

local function close_current_buffer()
  if vim.bo.buftype == "terminal" then
    vim.cmd.bdelete({ bang = true })
    return
  end

  vim.cmd.bdelete()
end

vim.keymap.set("n", "<leader>e", function()
  open_neo_tree({ toggle = true, reveal = true })
end, { desc = "Explorer: toggle" })

vim.keymap.set("n", "<leader>E", function()
  open_neo_tree({ action = "focus", dir = vim.fn.getcwd() })
end, { desc = "Explorer: cwd" })

vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
  callback = resize_neo_tree,
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("user_terminal_keymaps", { clear = true }),
  pattern = "term://*",
  callback = function(event)
    local opts = {
      buffer = event.buf,
      silent = true,
    }

    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
    vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
    vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
    vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
    vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
  end,
})

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
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      },
    },
  },
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

    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

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
      vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 3000 })
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

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        integrations = {
          bufferline = true,
          mason = true,
          neotree = true,
          which_key = true,
        },
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "mason-org/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "html",
        "cssls",
        "jsonls",
        "bashls",
        "yamlls",
      },
      automatic_enable = true,
    },
  },
  {
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
  },
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    lazy = false,
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              preview_width = 0.55,
              preview_cutoff = 80,
              prompt_position = "top",
            },
          },
          sorting_strategy = "ascending",
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      telescope.load_extension("fzf")

      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find: files" })
      vim.keymap.set("n", "<leader>fw", builtin.live_grep, { desc = "Find: word search" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find: buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find: help" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Find: recent files" })
      vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Find: commands" })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>e", desc = "Explorer: toggle" },
        { "<leader>E", desc = "Explorer: cwd" },
        { "<leader>0", desc = "Buffer: last tab" },
        { "<leader>1", desc = "Buffer: tab 1" },
        { "<leader>2", desc = "Buffer: tab 2" },
        { "<leader>3", desc = "Buffer: tab 3" },
        { "<leader>4", desc = "Buffer: tab 4" },
        { "<leader>5", desc = "Buffer: tab 5" },
        { "<leader>6", desc = "Buffer: tab 6" },
        { "<leader>7", desc = "Buffer: tab 7" },
        { "<leader>8", desc = "Buffer: tab 8" },
        { "<leader>9", desc = "Buffer: tab 9" },
        { "<leader>b", group = "buffer" },
        { "<leader>bd", desc = "Buffer: close" },
        { "<leader>f", group = "find" },
        { "<leader>fb", desc = "Find: buffers" },
        { "<leader>fc", desc = "Find: commands" },
        { "<leader>ff", desc = "Find: files" },
        { "<leader>fh", desc = "Find: help" },
        { "<leader>fr", desc = "Find: recent files" },
        { "<leader>fw", desc = "Find: word search" },
        { "<leader>l", group = "language" },
        { "<leader>lc", desc = "Config: open init.lua" },
        { "<leader>ld", desc = "LSP: line diagnostic" },
        { "<leader>lf", desc = "LSP: format" },
        { "<leader>r", group = "refactor" },
        { "<leader>rn", desc = "LSP: rename" },
        { "<leader>t", group = "terminal" },
        { "<leader>ts", desc = "Terminal: select" },
        { "<leader>tt", desc = "Terminal: toggle bottom" },
        { "<leader>tT", desc = "Terminal: full buffer" },
        { "<leader>c", group = "code" },
        { "<leader>ca", desc = "LSP: code action" },
        { "[d", desc = "LSP: previous diagnostic" },
        { "]d", desc = "LSP: next diagnostic" },
        { "gd", desc = "LSP: definition" },
        { "gD", desc = "LSP: declaration" },
        { "gi", desc = "LSP: implementation" },
        { "gr", desc = "LSP: references" },
        { "K", desc = "LSP: hover" },
        { "<S-h>", desc = "Buffer: previous tab" },
        { "<S-l>", desc = "Buffer: next tab" },
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    lazy = false,
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          end

          return math.floor(vim.o.columns * 0.4)
        end,
        direction = "horizontal",
        hide_numbers = true,
        shade_terminals = false,
        start_in_insert = true,
        persist_size = true,
        persist_mode = true,
        close_on_exit = true,
        auto_scroll = true,
        winbar = {
          enabled = true,
          name_formatter = function(term)
            return "terminal " .. term.id
          end,
        },
      })

      vim.keymap.set("n", "<leader>tt", "<Cmd>ToggleTerm direction=horizontal<CR>", {
        desc = "Terminal: toggle bottom",
      })
      vim.keymap.set("n", "<leader>tT", open_terminal_buffer, {
        desc = "Terminal: full buffer",
      })
      vim.keymap.set("n", "<leader>ts", "<Cmd>TermSelect<CR>", {
        desc = "Terminal: select",
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
      local bufferline = require("bufferline")

      bufferline.setup({
        highlights = require("catppuccin.special.bufferline").get_theme(),
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          indicator = {
            style = "underline",
          },
          modified_icon = "●",
          show_buffer_close_icons = false,
          show_close_icon = false,
          show_tab_indicators = true,
          separator_style = "thin",
          always_show_bufferline = true,
          offsets = {
            {
              filetype = "neo-tree",
              text = "Explorer",
              text_align = "center",
              separator = true,
            },
          },
        },
      })
      use_terminal_background()

      vim.keymap.set("n", "<S-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Buffer: next tab" })
      vim.keymap.set("n", "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Buffer: previous tab" })
      vim.keymap.set("n", "<leader>0", "<Cmd>BufferLineGoToBuffer -1<CR>", { desc = "Buffer: last tab" })
      vim.keymap.set("n", "<leader>bd", close_current_buffer, { desc = "Buffer: close" })

      for i = 1, 9 do
        vim.keymap.set("n", "<leader>" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", {
          desc = "Buffer: tab " .. i,
        })
      end
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        enable_diagnostics = true,
        enable_git_status = true,
        filesystem = {
          bind_to_cwd = true,
          follow_current_file = {
            enabled = true,
          },
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_ignored = false,
            hide_hidden = false,
            hide_by_name = {},
            hide_by_pattern = {},
            never_show = {},
            never_show_by_pattern = {},
          },
          hijack_netrw_behavior = "open_default",
          use_libuv_file_watcher = true,
        },
        window = {
          position = "right",
          width = neo_tree_width(),
        },
      })
    end,
  },
})
