local o = vim.opt
local map = vim.api.nvim_set_keymap

o.number = true
o.relativenumber = true
o.termguicolors = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.clipboard = "unnamedplus"
o.mouse = "a"
o.updatetime = 250
o.textwidth = 80
o.colorcolumn = "80"
o.completeopt = { "menuone", "noselect", "popup" }

vim.g.mapleader = " "
map("i", "jk", "<esc>", {})
map("n", "<leader>w", ":w<cr>", {})
map("n", "<leader>x", ":bdelete<cr>", {})
map("n", "<leader>c", ":!", {})
map("n", "<leader>e", ":Ex<cr>", {})
map("n", "<leader>nh", ":nohl<cr>", {})
map("n", "<leader>ff", ":FZF<cr>", {})
vim.keymap.set("n", "<leader>hh", function()
	local current_diag = vim.diagnostic.config()
	local diag_status = true
	if current_diag and current_diag.virtual_text ~= nil then
		diag_status = not current_diag.virtual_text
	end
	vim.diagnostic.config({ virtual_text = diag_status })
	local hint_status = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
	vim.lsp.inlay_hint.enable(hint_status, { bufnr = 0 })
	local msg = string.format(
		"LSP View -> diagnostics-text: %s | Inlay Hints: %s",
		diag_status and "on" or "off",
		hint_status and "on" or "off"
	)
	vim.notify(msg, vim.log.levels.INFO)
end, { desc = "Toggle Virtual Text and Inlay Hints" })
--aucommands
vim.api.nvim_create_user_command("E", function()
	vim.cmd("edit $MYVIMRC")
end, { desc = "edit config" })

vim.pack.add({
	{ src = "https://github.com/junegunn/fzf.vim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/j-hui/fidget.nvim" },
	{ src = "https://github.com/mrcjkb/rustaceanvim" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/romus204/tree-sitter-manager.nvim" },
	{ src = "https://github.com/saghen/blink.cmp", version = "v1.10.2" },
})
require("oil").setup()
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
require("nvim-autopairs").setup({})
require("tree-sitter-manager").setup({
	border = "rounded",
	auto_install = true,
	noauto_install = {},
	highlight = true,
	nerdfont = true,
})
require("blink.cmp").setup({})
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		rust = { "rustfmt" },
		javascript = { "prettier" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = { library = { vim.env.VIMRUNTIME } },
			hint = { enable = true },
		},
	},
})
vim.lsp.enable("lua_ls")

vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--inlay-hints=true",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	root_markers = { ".git", "compile_commands.json", "compile_flags.txt" },
})
vim.lsp.enable("clangd")

require("fidget").setup({})
vim.notify = require("fidget").notify

function WEBDEV()
	require("conform").setup({
		formatters_by_ft = {
			nix = { "nixfmt" },
			lua = { "stylua" },
			html = { "prettier" },
			jsx = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			less = { "prettier" },
			vue = { "prettier" },
			svelte = { "prettier" },
			markdown = { "prettier" },
			yaml = { "prettier" },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	})

	-- LSP Configurations & Snippets
	vim.pack.add({
		{ src = "https://github.com/neovim/nvim-lspconfig" },
		{ src = "https://github.com/rafamadriz/friendly-snippets" },
		{ src = "https://github.com/L3MON4D3/LuaSnip" },
	})

	require("luasnip.loaders.from_vscode").load({})
	local servers = {
		"emmet_ls",
		"vtsls",
		"html",
		"cssls",
		"jsonls",
		"eslint",
		"vue_ls",
		"svelte",
		"tailwindcss",
	}
	vim.lsp.enable(servers)
end
--WEBDEV()
