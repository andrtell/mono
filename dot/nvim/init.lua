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
-- KEYS --
----------
function key(m, l, r, opts)
	opts = opts or {silent = true}
	vim.keymap.set(m, l, r, opts)
end

key("n", "<BS>", ":nohl<CR>") 
key("i", "jk", "<ESC>") 
key("n", "<C-h>", "<C-w><C-h>")
key("n", "<C-l>", "<C-w><C-l>")
key("n", "<C-j>", "<C-w><C-j>")
key("n", "<C-k>", "<C-w><C-k>")
key("n", "-", ":Ex<CR>")
key("n", "*", "g*")

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
	{"LeapLabelPrimary",         { bg = "#fbe0fb" }},
	{"DiagnosticUnderlineError", { bg = "#fbe4e4" }},
	{"DiagnosticUnnecessary", 	 { bg = "#fbe4e4" }},
	{"DiagnosticDeprecated", 	 { bg = "#fbe4e4" }},
	{"DiagnosticUnderlineWarn",  { bg = "#fbe4e4" }},
	{"DiagnosticUnderlineInfo",  { bg = "#fbe4e4" }},
	{"DiagnosticUnderlineHint",  { bg = "#fbe4e4" }},
}

for _, colr in ipairs(colors) do
	vim.api.nvim_set_hl(0, colr[1], colr[2])
end

----------------
-- STATUSLINE --
----------------
vim.o.statusline = " %f %m%r %= %{&filetype} | %{&fenc} | %3l  "

-------------
-- AUGROUP --
-------------
local init_group = vim.api.nvim_create_augroup("netrw", {clear = true})

------------
--- NETRW --
------------
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = "\\(^\\|\\s\\s\\)\\zs\\.\\S\\+"
vim.g.netrw_keepdir = 0

vim.api.nvim_create_autocmd(
"FileType", 
{
	pattern = {"netrw"},
	group = init_group,
	callback = function () 
		local keys = { 
			{"<ESC>", ":Sayonara!<CR>"},
			{"h", "-"},
			{"l", "<CR>"},
			{"<left>", "-"},
			{"<right>", "<CR>"},
			{".", "gh"}, 
			{"H", "u"}
		}
		local opts = { silent = true, buffer = true, remap = true }
		for _, k in ipairs(keys) do
			vim.keymap.set("n", k[1], k[2], opts)
		end
	end
}
)

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

----------------
-- LSP CONFIG --
----------------
vim.opt.rtp:prepend(vendor_path .. "nvim-lspconfig")
local lspconfig = require "lspconfig"
lspconfig.gopls.setup {}

---------------
-- DIAG FLOW --
---------------
vim.opt.rtp:prepend(vendor_path .. "diagflow.nvim")
require "diagflow".setup {
    show_borders = true, 
    scope = "line"
}
