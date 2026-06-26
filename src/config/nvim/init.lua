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
o.colorcolumn= "80"

vim.g.mapleader = " "
map("i","jk","<esc>", {})
map("n","<leader>w",":w<cr>", {})
map("n","<leader>x",":bdelete<cr>", {})
map("n","<leader>c",":!", {})
map("n","<leader>e",":Ex<cr>", {})
map("n","<leader>nh",":nohl<cr>", {})

