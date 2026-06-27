-- =============================================================================
-- OPTIONS
-- =============================================================================
local o = vim.opt

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

-- =============================================================================
-- KEYMAPS
-- =============================================================================
local map = vim.api.nvim_set_keymap

vim.g.mapleader = " "

map("i", "jk", "<esc>", {})
map("n", "<leader>w", ":w<cr>", {})
map("n", "<leader>x", ":bdelete<cr>", {})
map("n", "<leader>c", ":!", {})
map("n", "<leader>e", ":Ex<cr>", {})
map("n", "<leader>nh", ":nohl<cr>", {})
map("n", "<leader>ff", ":FZF<cr>", {})

vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory in float" })

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

-- =============================================================================
-- STATUSLINE
-- =============================================================================
function _G.get_lsp_and_formatter()
	local lsps, fmts = {}, {}
	local lsp_ok, clients = pcall(vim.lsp.get_clients, { bufnr = 0 })
	for _, c in ipairs(lsp_ok and clients or {}) do
		table.insert(lsps, c.name)
	end

	local cf_ok, cf = pcall(require, "conform")
	local fmt_ok, formatters = pcall(cf_ok and cf.list_formatters or function() end, 0)
	for _, f in ipairs(fmt_ok and formatters or {}) do
		if f.available then
			table.insert(fmts, f.name)
		end
	end

	return (#lsps > 0 and "[" .. table.concat(lsps, ",") .. "]" or "[-]")
		.. " | "
		.. (#fmts > 0 and "[" .. table.concat(fmts, ",") .. "]" or "[-]")
end

vim.opt.statusline = "%F %m %r %y %= %{v:lua._G.get_lsp_and_formatter()}  %l:%c %P"

-- =============================================================================
-- USER COMMANDS
-- =============================================================================
vim.api.nvim_create_user_command("E", function()
	vim.cmd("edit $MYVIMRC")
end, { desc = "edit config" })

-- =============================================================================
-- SIDEBAR SPACER (AUTOCMDS & LOGIC)
-- =============================================================================
local function is_spacer_win(win_id)
	if not vim.api.nvim_win_is_valid(win_id) then
		return false
	end
	local ok, val = pcall(vim.api.nvim_win_get_var, win_id, "is_margin_spacer")
	return ok and val == true
end

local function ensure_margin_layout()
	local spacer_win = nil
	local normal_win_count = 0
	local all_wins = vim.api.nvim_list_wins()

	for _, win in ipairs(all_wins) do
		if is_spacer_win(win) then
			spacer_win = win
		else
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].buftype == "" then
				normal_win_count = normal_win_count + 1
			end
		end
	end

	if spacer_win and normal_win_count == 0 then
		vim.api.nvim_set_current_win(spacer_win)
		vim.cmd("vnew")
		vim.cmd("vertical resize 30")
		vim.cmd("wincmd l")
		return
	end

	if not spacer_win then
		vim.cmd("topleft vnew")
		vim.cmd("vertical resize 30")
		vim.api.nvim_win_set_var(0, "is_margin_spacer", true)

		vim.wo.winfixwidth = true
		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.wo.signcolumn = "no"
		vim.wo.foldcolumn = "0"
		vim.bo.buftype = "nofile"
		vim.bo.bufhidden = "wipe"

		vim.cmd("wincmd l")
	end
end

vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufDelete" }, {
	callback = function()
		vim.schedule(ensure_margin_layout)
	end,
})

vim.api.nvim_create_autocmd("WinEnter", {
	callback = function()
		if is_spacer_win(0) then
			vim.cmd("wincmd l")
		end
	end,
})

-- =============================================================================
-- PACKAGE MANAGER
-- =============================================================================
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

-- =============================================================================
-- PLUGINS CONFIGURATION
-- =============================================================================
require("oil").setup({
	float = {
		max_width = 80,
		max_height = 20,
		border = "rounded",
		win_options = {
			winblend = 0,
		},
	},
	view_options = {
		show_hidden = false,
	},
})

require("nvim-autopairs").setup({})

require("tree-sitter-manager").setup({
	border = "rounded",
	auto_install = true,
	noauto_install = {},
	highlight = true,
	nerdfont = true,
})

require("blink.cmp").setup({})

require("fidget").setup({})
vim.notify = require("fidget").notify

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

-- =============================================================================
-- CORE LSP CONFIGURATION
-- =============================================================================
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

-- =============================================================================
-- MODULE: WEB DEVELOPMENT OVERRIDE
-- =============================================================================
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

-- WEBDEV()
