--[[ ////////////////////////////////////////////////////////////////////
--   // FILE        :: init.lua
--   // AUTHOR      :: rowsred
--   // DATE        :: 2026-06-10
--   // HOST_OS     :: Linux
--   // DESC        :: just keep , code
//////////////////////////////////////////////////////////////////// --]]

-- =============================================================================
-- 1. GLOBAL & GLOBAL ENVIRONMENT
-- =============================================================================
vim.env.CC = "clang"
vim.g.mapleader = " "

-- =============================================================================
-- 2. NEVIM OPTIONS (VIM.OPT)
-- =============================================================================
local o = vim.opt
o.number = true
o.relativenumber = true
o.clipboard = "unnamedplus"
o.tabstop = 4
o.pumheight = 10
o.completeopt = { "menu", "menuone", "noselect", "noinsert", "popup", "fuzzy" }

-- =============================================================================
-- 3. KEYMAPS (MANUAL)
-- =============================================================================
local map = vim.api.nvim_set_keymap

-- Normal Mode Mappings
map("n", "<leader>w", ":w<cr>", {})
map("n", "<leader>c", ":!", {})
map("n", "<leader>x", ":bdel<cr>", {})
map("n", "<leader>nh", ":nohl<cr>", {})

-- Insert Mode Mappings
map("i", "jk", "<esc>", {})

-- Toggle Virtual Text
vim.keymap.set("n", "<leader>hh", function()
	local show = not vim.diagnostic.config().virtual_text
	vim.diagnostic.config({ virtual_text = show })
	vim.notify("Virtual text " .. (show and "ON" or "OFF"), show and 2 or 3)
end, { desc = "Toggle Virtual Text" })

-- =============================================================================
-- 4. USER COMMANDS & CUSTOM FUNCTIONS
-- =============================================================================
-- Shortcut untuk edit config
vim.api.nvim_create_user_command("E", function()
	vim.cmd("edit $MYVIMRC")
end, { desc = "edit config" })

-- Fungsi pembantu untuk Statusline (LSP & Formatter)
function _G.get_lsp_and_formatter()
	local active_lsps = {}
	local lsp_ok, buf_clients = pcall(vim.lsp.get_clients, { bufnr = 0 })
	if lsp_ok and buf_clients then
		for _, client in ipairs(buf_clients) do
			if client.name then
				table.insert(active_lsps, client.name)
			end
		end
	end

	local active_formatters = {}
	local conform_ok, conform = pcall(require, "conform")
	if conform_ok then
		local fmt_ok, formatters = pcall(conform.list_formatters, 0)
		if fmt_ok and formatters then
			for _, formatter in ipairs(formatters) do
				if formatter.available and formatter.name then
					table.insert(active_formatters, formatter.name)
				end
			end
		end
	end

	local lsp_str = #active_lsps > 0 and ("󱙋 : [" .. table.concat(active_lsps, ", ") .. "]") or "󰴀 "
	local fmt_str = #active_formatters > 0 and ("  [" .. table.concat(active_formatters, ", ") .. "]") or "󰘦 "
	return lsp_str .. " | " .. fmt_str
end

-- Custom Header Generator Command
vim.api.nvim_create_user_command("Header", function()
	local ft = vim.bo.filetype
	local filename = vim.fn.expand("%:t")
	if filename == "" then
		filename = "untitled"
	end
	local current_date = os.date("%Y-%m-%d")
	local current_os = "Unknown"
	if vim.uv.os_uname().sysname == "Linux" then
		current_os = "Linux"
	elseif vim.uv.os_uname().sysname == "Darwin" then
		current_os = "macOS"
	elseif vim.fn.has("win32") == 1 then
		current_os = "Windows"
	elseif vim.uv.os_uname().sysname:find("BSD") then
		current_os = "FreeBSD"
	end

	local function generate_lines(c_open, c_mid, c_close_start, c_close_end)
		c_close_end = c_close_end or ""
		return {
			c_open .. "-----------------------------------------------------------------------",
			c_mid .. "  // FILE        :: " .. filename,
			c_mid .. "  // AUTHOR      :: rowsred",
			c_mid .. "  // DATE        :: " .. current_date,
			c_mid .. "  // HOST_OS     :: " .. current_os,
			c_mid .. "  // DESC        :: just keep , code",
			c_close_start .. "-----------------------------------------------------------------------" .. c_close_end,
		}
	end

	local lines = {}
	if ft == "lua" then
		lines = generate_lines("--[[ ", "-- ", " ", " --]]")
	elseif vim.tbl_contains({ "c", "cpp", "css" }, ft) then
		lines = generate_lines("/* ", " ", " ", " */")
	elseif
		vim.tbl_contains({ "rust", "javascript", "typescript", "javascriptreact", "typescriptreact", "jsonc" }, ft)
	then
		lines = generate_lines("// ", "// ", "// ", "")
	elseif vim.tbl_contains({ "nix", "conf", "toml", "sh" }, ft) then
		lines = generate_lines("# ", "# ", "# ", "")
	elseif vim.tbl_contains({ "html", "vue", "svelte" }, ft) then
		lines = generate_lines("")
	else
		lines = generate_lines("# ", "# ", "# ", "")
	end

	vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
	vim.api.nvim_win_set_cursor(0, { 6, string.len(lines[6]) })
end, {})

-- =============================================================================
-- 5. STATUSLINE CONFIGURATION
-- =============================================================================
local left_side = " %f %m"
local alignment = "%="
local right_side = "%{v:lua._G.get_lsp_and_formatter()}  %l:%c "
vim.opt.statusline = left_side .. alignment .. right_side

-- =============================================================================
-- 6. UTILITY PLUGINS (AUTOPAIRS, OIL, SNACKS, TS, FIDGET)
-- =============================================================================
-- Nvim Autopairs
vim.pack.add({ { src = "https://github.com/windwp/nvim-autopairs" } })
require("nvim-autopairs").setup({})

-- Oil.nvim
vim.pack.add({ { src = "https://github.com/stevearc/oil.nvim" } })
require("oil").setup({
	float = {
		max_width = 0.8,
		max_height = 0.8,
		border = "rounded",
		win_options = { winblend = 0 },
	},
})
vim.keymap.set("n", "<leader>e", ":Oil --float<cr>", { desc = "Open Oil File Explorer" })

-- Snacks.nvim
vim.pack.add({ { src = "https://github.com/folke/snacks.nvim" } })
Snacks = require("snacks")
Snacks.setup({
	bigfile = { enabled = true },
	dashboard = { enabled = false },
	explorer = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true },
	picker = { enabled = true },
	notifier = { enabled = true },
	quickfile = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	words = { enabled = true },
})
vim.keymap.set("n", "<leader>ff", "<cmd>lua Snacks.picker.files()<CR>", { desc = "Snacks Picker: Smart Find Files" })

-- Tree-sitter Manager
vim.pack.add({ { src = "https://github.com/romus204/tree-sitter-manager.nvim" } })
require("tree-sitter-manager").setup({
	auto_install = true,
	highlight = true,
})

-- Fidget (LSP Progress)
vim.pack.add({ { src = "https://github.com/j-hui/fidget.nvim" } })
require("fidget").setup({})

-- Rustaceanvim
vim.pack.add({ { src = "https://github.com/mrcjkb/rustaceanvim" } })

-- =============================================================================
-- 7. CORE ENVIRONMENT SETUP (WEBDEV ONLY)
-- =============================================================================
function WEBDEV()
	-- Code Formatter (Conform)
	vim.pack.add({ { src = "https://github.com/stevearc/conform.nvim" } })
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

	vim.lsp.config("lua_ls", {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		settings = {
			Lua = {
				workspace = {
					library = {
						vim.env.VIMRUNTIME,
						vim.api.nvim_get_runtime_file("", true),
					},
				},
			},
		},
	})

	-- Mass-enable LSP Servers
	local servers = {
		"lua_ls",
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

WEBDEV()

-- =============================================================================
-- 8. AUTO-COMPLETION ENGINE (BLINK.CMP)
-- =============================================================================
vim.pack.add({ { src = "https://github.com/saghen/blink.cmp", version = "v1.10.2" } })
local cmp = require("blink.cmp")
cmp.setup({
	completion = { documentation = { auto_show = false } },
	sources = { default = { "lsp", "path", "snippets" } },
})
