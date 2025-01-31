------------
-- LEADER --
------------
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-------------
-- OPTIONS --
-------------
local opt = {
	ignorecase = true, 
	smartcase = true, 
	updatetime = 250, 
	timeoutlen = 300, 
	scrolloff = 10, 
	mouse = "a", 
	breakindent = true, 
	tabstop = 4, 
	shiftwidth = 4, 
	laststatus = 3, 
	signcolumn = "yes:1", 
	cursorline = false, 
	showcmd = false, 
	showmode = false,
	shortmess = "Ita",
	swapfile = false
}

for key, value in pairs(opt) do
	vim.opt[key] = value
end

vim.schedule(function ()
	vim.opt.clipboard = "unnamedplus"
end)

----------
-- UTIL --
----------
function key(m, l, r, opts)
	opts = opts or {silent = true}
	vim.keymap.set(m, l, r, opts)
end

----------
-- KEYS --
----------
key("n", "<BS>", "<cmd>nohl<CR>") 
key("i", "jk", "<esc>") 
key("n", "<C-h>", "<C-w><C-h>")
key("n", "<C-l>", "<C-w><C-l>")
key("n", "<C-j>", "<C-w><C-j>")
key("n", "<C-k>", "<C-w><C-k>")
key("n", "-", ":Ex<cr>")
key("n", "*", "g*")
key("n", "<C-Up>", "<cmd>resize +2<cr>")
key("n", "<C-Down>", "<cmd>resize -2<cr>")
key("n", "<C-Left>", "<cmd>vertical resize -2<cr>")
key("n", "<C-Right>", "<cmd>vertical resize +2<cr>")
key("n", "<S-h>", "<cmd>bprevious<cr>")
key("n", "<S-l>", "<cmd>bnext<cr>")
key("v", "<", "<gv")
key("v", ">", ">gv")

------------
-- COLORS --
------------
vim.o.background = "light"

-- reset
for hlgrp, _ in pairs(vim.api.nvim_get_hl(0, {})) do
	if type(hlgrp) == "string" then
		vim.api.nvim_set_hl(0, hlgrp, { fg = "#030303", bg = "#fefefe" }) 
	end
end

local colors = {
	{"Search",      { bg = "#f9edd7" }},
	{"IncSearch",   { bg = "#f9edd7" }},
	{"CurSearch",   { bg = "#f9edd7" }},
	{"Visual",      { bg = "#e2eafb" }},
	{"VisualNOS",   { bg = "#e2eafb" }},
	{"MatchParen",  { bg = "#fbe4e4" }},
	{"Pmenu",       { bg = "#f0f0f0" }},
	{"PmenuSel",    { bg = "#d9d9d9" }},
	{"StatusLine",  { bg = "#ebebeb" }},
	{"WinSeparator",{ fg = "#ebebeb" }},
	{"EndOfBuffer", { fg = "#fefefe" }},
	{"Comment",     { fg = "#9d9fa4" }},
	{"@comment",    { fg = "#9d9fa4" }},
	{"LeapLabelPrimary", { bg = "#fbe0fb" }},
	{"DiagnosticUnderlineError", { bg = "#fbe4e4" }},
	{"DiagnosticUnnecessary",	{ bg = "#fbe4e4" }},
	{"DiagnosticDeprecated",	{ bg = "#fbe4e4" }},
	{"DiagnosticUnderlineWarn", { bg = "#fbe4e4" }},
	{"DiagnosticUnderlineInfo", { bg = "#fbe4e4" }},
	{"DiagnosticUnderlineHint", { bg = "#fbe4e4" }},
}

for _, colr in ipairs(colors) do
	vim.api.nvim_set_hl(0, colr[1], colr[2])
end

----------------
-- STATUSLINE --
----------------
vim.o.statusline = " %f %m%r %= %{&filetype} | %{&fenc} | %3l  "

------------
--- NETRW --
------------
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = "\\(^\\|\\s\\s\\)\\zs\\.\\S\\+"
vim.g.netrw_keepdir = 0

vim.api.nvim_create_autocmd("FileType", {
	pattern = {"netrw"},
	group = vim.api.nvim_create_augroup("NETRW", {clear = true}),
	callback = function () 
		local opts = { silent = true, buffer = true, remap = true }
		key("n", "<ESC>", ":Sayonara!<CR>", opts)
		key("n", "h", "-", opts)
		key("n", "l", "<CR>", opts)
		key("n", "<left>", "-", opts)
		key("n", "<right>", "<CR>", opts)
		key("n", ".", "gh", opts) 
		key("n", "H", "u", opts)
	end
})

-----------------
-- DIAGNOSTICS --
-----------------
vim.cmd("sign define DiagnosticSignError text= texthl= linehl= numhl=")
vim.cmd("sign define DiagnosticSignWarn text= texthl= linehl= numhl=")

local ul_ns = vim.api.nvim_create_namespace("ul_ns")
local ul_show = vim.diagnostic.handlers.underline.show
local ul_hide = vim.diagnostic.handlers.underline.hide

vim.diagnostic.handlers.underline = {
	show = function(_, bufnr, d, o)
		for i, _ in ipairs(d) do
			if (d[i].end_col == d[i].col) then
				local lastcol = vim.fn.strlen(vim.fn.getline("."))
				if lastcol == d[i].col then
					d[i].col = 0
				else
					d[i].end_col = lastcol
				end
			end
		end
		return ul_show(ul_ns, bufnr, d, {})
	end, 
	hide = function (_, bufnr)
		return ul_hide(ul_ns, bufnr)
	end
}

---------
-- LSP --
---------
vim.api.nvim_create_autocmd('FileType',{
	pattern = {"go", "gomod", "gowork", "gotmpl"},
	group = vim.api.nvim_create_augroup("GO", {clear = true}),
	callback = function(ev)
		vim.lsp.start({
			cmd = {"gopls"}, 
			name = "gopls", 
			single_file_support = true,
			root_dir = vim.fs.root(ev.buf, {"go.work", "go.mod", ".git"}),
		})
	end
})

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup("LSP-ATTACH", {clear = true}),
	callback = function(ev)
		key("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
		key("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
	end,
})

--------------
-- PACKAGES --
--------------
local vendor_path = vim.fn.stdpath("config") .. "/vendor/"

----------
-- LEAP --
----------
vim.opt.rtp:prepend(vendor_path .. "leap.nvim")

require "leap".setup {}

key("n", "s", "<Plug>(leap)")
key("n", "S", "<Plug>(leap-from-window)")
key({"x", "o"}, "s", "<Plug>(leap-forward)")
key({"x", "o"}, "S", "<Plug>(leap-backward)")

--------------
-- SAYONARA --
--------------
vim.opt.rtp:prepend(vendor_path .. "vim-sayonara")

------------------
-- GUESS INDENT --
------------------
vim.opt.rtp:prepend(vendor_path .. "guess-indent.nvim")
require "guess-indent".setup {}

---------------
-- DIAG FLOW --
---------------
vim.opt.rtp:prepend(vendor_path .. "diagflow.nvim")
require "diagflow".setup {
	show_borders = true, 
	scope = "line"
}
