------------------------------------------------------------
-- ╔╗╔╔═╗╔═╗╦  ╦╦╔╦╗
-- ║║║║╣ ║ ║╚╗╔╝║║║║
-- ╝╚╝╚═╝╚═╝ ╚╝ ╩╩ ╩
------------------------------------------------------------                 

local g = vim.g
local o = vim.opt

------------------------------------------------------------
-- OPTION
------------------------------------------------------------

o.breakindent = true
o.background  = "light"
o.cursorline  = false
o.gdefault    = true
o.laststatus  = 3
o.mouse       = "a"
o.number      = false
o.scrolloff   = 21
o.shortmess   = "Ita"
o.showcmd     = false
o.showmode    = false
o.signcolumn  = "yes:1"
o.smartcase   = true
o.swapfile    = false
o.timeoutlen  = 300
o.updatetime  = 250
o.statusline  = " %f %m%r %= %{&filetype} | %n | %{&fenc} | %3l : %2c  "

vim.schedule(function()
  o.clipboard = "unnamedplus"
end)

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local hi = function (group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local create_autocmd = vim.api.nvim_create_autocmd

local create_augroup = vim.api.nvim_create_augroup

local create_buf_augroup=function(name, buf) 
  local group=create_augroup(name, {clear=false}) 
  vim.api.nvim_clear_autocmds({group=group, buffer=buf})
  return group
end

local imap = function(l, r, opts) vim.keymap.set("i", l, r, opts or {}) end
local nmap = function(l, r, opts) vim.keymap.set("n", l, r, opts or {}) end

------------------------------------------------------------
-- KEY
------------------------------------------------------------

g.mapleader = " "
g.maplocalleader = ","

imap("jk", "<esc>")

nmap("<bs>",      ":nohl<cr>")
nmap("*",         "g*")
nmap("-",         ":Ex<cr>")
nmap("<c-h>",     "<c-w><c-h>")
nmap("<c-l>",     "<c-w><c-l>")
nmap("<c-j>",     "<c-w><c-j>")
nmap("<c-k>",     "<c-w><c-k>")
nmap("<c-up>",    ":resize +2<cr>")
nmap("<c-down>",  ":resize -2<cr>")
nmap("<c-left>",  ":vertical resize -2<cr>")
nmap("<c-right>", ":vertical resize +2<cr>")
nmap("<S-h>",     ":bprevious<cr>")
nmap("<S-l>",     ":bnext<cr>")
nmap("s",         "<Plug>(leap)")
nmap("S",         "<Plug>(leap-from-window)")

nmap("]d", function () vim.diagnostic.goto_next {float=false} end)
nmap("[d", function () vim.diagnostic.goto_prev {float=false} end)

-- vim.keymap.del({'i', 's'}, "<Tab>")
-- vim.keymap.del({'i', 's'}, "<S-Tab>")

local function set_snippet_jump(direction, key)
  local handle_keypress = function()
    if vim.snippet.active({ direction = direction }) then
      return string.format('<Cmd>lua vim.snippet.jump(%d)<CR>', direction)
    else
      return key
    end
  end
  local opts = {
    expr = true,
    silent = true,
  }
  vim.keymap.set({ 'i', 's' }, key, handle_keypress, opts)
end

set_snippet_jump(1, '<C-k>')
set_snippet_jump(-1, '<C-j>')

------------------------------------------------------------
-- NETRW
------------------------------------------------------------

g.netrw_banner = 0
g.netrw_keepdir = 0
g.netrw_list_hide="\\(^\\|\\s\\s\\)\\zs\\.\\S\\+"

create_autocmd("filetype", {
  pattern="netrw",
  group=create_augroup("netrw-1", {}),
  callback=function ()
    local opt = { silent=true, buffer=true, remap=true }

    nmap("<esc>", ":Sayonara!<cr>",  opt)
    nmap("h",     "-",               opt)
    nmap("l",     "<cr>",            opt)
    nmap(".",     "gh",              opt)
    nmap("H",     "h",               opt)

    hi("CursorLine", {bg="#efefef"})
    hi("NetrwDir", {bg="none"})
    hi("NetrwExe", {bg="none"})
  end,
})

------------------------------------------------------------
-- TINY INLINE
------------------------------------------------------------

require('tiny-inline-diagnostic').setup({
  -- preset = "minimal",
  signs = {
    left = "",
    right = "",
    diag = "",
    arrow = " ",
    up_arrow = "",
    vertical = " ",
    vertical_end = " ",
  },
})

------------------------------------------------------------
-- GO
------------------------------------------------------------

vim.lsp.enable('gopls')

create_autocmd("BufEnter", {
  group=create_augroup("go-1", {}),
  pattern="*.go",
  callback = function ()
    nmap("<leader>i", "<Plug>(go-info)")
  end
})

------------------------------------------------------------
-- TREESITTER
------------------------------------------------------------

require('nvim-treesitter.configs').setup {
  auto_install=true,
  ensure_installed = {
    "bash", "dockerfile", "json", "lua", "python", "sql", "yaml", 
    "go", "gomod", "gowork", "gotmpl"
  },
  highlight={
    enable=true
  }
}

------------------------------------------------------------
-- CMP
------------------------------------------------------------

local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
  formatting = {
    expandable_indicator = false,
    fields = {"abbr"}
  },
  window = {
    completion = cmp.config.window.bordered({
      border={" "},
      winhighlight = 'Normal:Pmenu,FloatBorder:PMenu,CursorLine:PmenuSel,Search:None',
    }),
    documentation = cmp.config.disable
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-k>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({{ name = 'nvim_lsp' }}, {{ name = 'buffer' }})
})

------------------------------------------------------------
-- DIAGNOSTIC
------------------------------------------------------------

vim.diagnostic.config {
  virtual_text=false,
  signs = { 
    text = { 
      [vim.diagnostic.severity.ERROR] = "", 
      [vim.diagnostic.severity.WARN] = "" 
    }
  }
}

local patch_diagnostic_underline = function (...) 
  local new_ns = vim.api.nvim_create_namespace "diagnostic-1"
  local old_show = vim.diagnostic.handlers.underline.show
  local old_hide = vim.diagnostic.handlers.underline.hide
  local new_show = function (_ns, buf, ds, opt)
    for _, d in ipairs(ds) do
      if d.col == d.end_col then
        local last_col = vim.fn.strlen(vim.fn.getline("."))
        if d.col == last_col then
          d.col = 0
        else
          d.end_col = last_col
        end
      end
    end
    return old_show(new_ns, buf, ds, opt)
  end
  local new_hide = function (_ns, buf)
    return old_hide(new_ns, buf) 
  end
  vim.diagnostic.handlers.underline = {show=new_show, hide=new_hide}
end

create_autocmd("VimEnter", {
  group=create_augroup("diagnostic-1", {}),
  callback=patch_diagnostic_underline
})

------------------------------------------------------------
-- COLOR
------------------------------------------------------------

local clear_highlight = function() 
  for hlgroup, _ in pairs(vim.api.nvim_get_hl(0, {})) do
    if type(hlgroup) == "string" then
      hi(hlgroup, {fg="#101010", bg="#fefefe"})
    end
  end
end

local set_highlight = function ()
  local red_fg = "#A90303"
  local green_fg = "#167e18"
  local blue_fg = "#001590"
  -- vim
  hi("normal",        {fg="#101010", bg="#fdfdfd"}) 
  hi("comment",       {fg="#9c9ea3"}) 
  hi("cursearch",     {bg="#faf2d8"})
  hi("endofbuffer",   {fg="#fefefe"})
  hi("floatborder",   {fg="#a4a4a4"})
  hi("incsearch",     {bg="#faf2d8"})
  hi("matchparen",    {bg="#e3eefd"})
  hi("PMenu",         {bg="#f0f0f1"})
  hi("PMenuSel",      {fg="#000000", bg="#dddde3"})
  hi("PMenuMatch",    {bg=none})
  hi("PMenuMatchSel", {bg=none})
  hi("search",        {bg="#faf2d8"})
  hi("statusline",    {bg="#ebebeb"}) 
  hi("visual",        {bg="#e4effe"})
  hi("visualnos",     {bg="#e4effe"})
  hi("winseparator",  {fg="#e2e2e2"})
  -- code
  hi("@comment",      {fg="#9c9ea3"})
  -- lua
  hi("@string.lua",              {fg=green_fg})
  hi("@string.escape.lua",       {fg=green_fg})
  hi("@boolean.lua",             {fg="purple"})
  hi("@number.lua",              {fg=red_fg})
  hi("@keyword.conditional.lua", {fg=blue_fg})
  hi("@keyword.function.lua",    {fg=blue_fg})
  hi("@keyword.lua",             {fg=blue_fg})
  hi("@keyword.operator.lua",    {fg=blue_fg})
  hi("@keyword.repeat.lua",      {fg=blue_fg})
  hi("@keyword.return.lua",      {fg=blue_fg})
  hi("@constructor.lua",         {fg="#3c3c45"})
  -- go
  hi("SnippetTabStop", {bg="#faf2d8"}) 
  -- tiny
  hi("TinyInlineDiagnosticVirtualTextError", {bg="#f0f0f1"})
  hi("TinyInlineDiagnosticVirtualTextWarn", {bg="#f0f0f1"})
  hi("TinyInlineDiagnosticVirtualTextHint", {bg="#f0f0f1"})
  hi("TinyInlineDiagnosticVirtualTextArrow", {fg="#efeff1"})
  -- leap
  hi("LeapLabelPrimary",         {bg="#fadffa"})
  -- diagnostic
  hi("DiagnosticUnderlineError", {bg="#fce5e5"})
  hi("DiagnosticUnderlineWarn",  {bg="#fbe5e5"})
  hi("DiagnosticUnderlineInfo",  {bg="#fbe5e5"})
  hi("DiagnosticUnderlineHint",  {bg="#fbe5e5"}) 
  hi("DiagnosticUnnecessary",    {bg="#fbe5e5"}) 
  hi("DiagnosticDeprecated",     {bg="#fbe5e5"})
  hi("DiagnosticFloatingError",  {fg="#030303"})
  hi("DiagnosticError",          {bg="#fbe5e5"})
  hi("DiagnosticWarn",           {bg="#fbe5e5"})
  -- netrw
end

set_highlight()

-- clear_highlight()
create_autocmd("colorscheme", {
  group=create_augroup("HIGHLIGHT", {}),
  pattern='default',
  callback=function () 
    clear_highlight()
    set_highlight()
  end,
})

vim.cmd("colorscheme default")
