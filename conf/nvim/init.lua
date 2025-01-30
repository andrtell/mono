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
    {"StatusLine",  { bg = "#f0f0f0" }},
    {"EndOfBuffer", { fg = "#fefefe" }},
    {"Comment",     { fg = "#9d9fa4" }},
    {"@comment",    { fg = "#9d9fa4" }},
    {"LeapPrimaryLabel",         { bg = "#fbe0fb" }},
    {"DiagnosticUnderlineError", { bg = "#fbe4e4" }},
    {"DiagnosticUnderlineWarn",  { bg = "#fbe4e4" }},
    {"DiagnosticUnderlineInfo",  { bg = "#fbe4e4" }},
    {"DiagnosticUnderlineHint",  { bg = "#fbe4e4" }},
}

for _, colr in ipairs(colors) do
    vim.api.nvim_set_hl(0, colr[1], colr[2])
end

----------
-- LAZY --
----------

local packages_dir = (vim.fn.stdpath("config") .. "/packages")

local lazy_dir = (packages_dir .. "/lazy.nvim")

if not vim.uv.fs_stat(lazy_dir) then
    local cmd = {
        "git", 
        "clone", 
        "--filter=blob:none", 
        "--branch=stable", 
        "https://github.com/folke/lazy.nvim.git", 
        lazy_dir
    }
    local out = vim.fn.system(cmd)
    local err = out:gsub("%s+", " ")
    if (vim.v.shell_error ~= 0) then
        io.write(err)
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazy_dir)

vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("lazy").setup({
    root = packages_dir, 
    lockfile = (packages_dir .. "/lazy-lock.json"), 
    spec = {
        {"udayvir-singh/tangerine.nvim"},
        {import = "spec"}
    }, 
    change_detection = {
        notify = false
    }, 
    install = {
        colorscheme = {}
    }
})

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
    showmode = false
}

for key, value in pairs(opt) do
    vim.opt[key] = value
end

vim.schedule(function ()
    vim.opt.clipboard = "unnamedplus"
end)

----------------
-- STATUSLINE --
----------------

vim.o.statusline = " %f %m%r %= %{&filetype} | %{&fenc} | %3l  "

----------
-- KEYS --
----------

local keys = {
    {"n", "<BS>", ":nohl<CR>"}, 
    {"i", "jk", "<ESC>"}, 
    {"n", "<C-h>", "<C-w><C-h>"}, 
    {"n", "<C-l>", "<C-w><C-l>"}, 
    {"n", "<C-j>", "<C-w><C-j>"}, 
    {"n", "<C-k>", "<C-w><C-k>"}, 
    {"n", "-", ":Ex<CR>"}, 
    {"n", "*", "g*"}
}

for _, key in ipairs(keys) do
    vim.keymap.set(key[1], key[2], key[3], {silent = true})
end

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
        return ul_show(ul_ns, bufnr, d, o)
    end, 
    hide = function (_, bufnr)
        return ul_hide(ul_ns, bufnr)
    end
}

----------------

require("tangerine").setup({
    compiler = {
        verbose = false,
        hooks = {
            "onsave",
            "oninit"
        },
    },
    keymaps = {
        eval_buffer = "<localleader>e",
        peek_buffer = "<localleader>l",
        peek_buffer = "go",
    },
})
