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
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			spec = {
				{ "<leader>l",  group = "lua/config" },
				{ "<leader>lc", desc = "Config: open init.lua" },
				{ "<leader>r",  group = "lsp" },
			},
		},
	},
	{
		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp", -- ensure this is on runtimepath before we require it
		},
		opts = {
			ensure_installed = { "lua_ls" },
			automatic_installation = true,
			-- optional: mason-lspconfig can also auto-enable installed servers by default
			-- (see note below)
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			-- Neovim 0.11+ configuration API
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				-- settings = { ... } -- add lua-language-server settings here if you want
			})

			-- Enable the server (start automatically for matching filetypes)
			vim.lsp.enable("lua_ls")
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
				}),
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>rf",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "n",
				desc = "Format buffer",
			},
		},
		opts = {
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				lua = { "stylua" },
			},
		},
	},
})

-- Keymaps when an LSP attaches to a buffer (Neovim 0.11+ style)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local bufnr = ev.buf
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		end

		map("n", "gd", vim.lsp.buf.definition, "LSP: go to definition")
		map("n", "gD", vim.lsp.buf.declaration, "LSP: go to declaration")
		map("n", "gr", vim.lsp.buf.references, "LSP: list references")
		map("n", "K", vim.lsp.buf.hover, "LSP: hover docs")
		map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename symbol")
		map("n", "<leader>ra", vim.lsp.buf.code_action, "LSP: code action")
	end,
})

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = { enable = false },
		},
	},
})
vim.lsp.enable("lua_ls")
