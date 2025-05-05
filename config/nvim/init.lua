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
-- KEY
------------------------------------------------------------

local i = function(l, r, opts) vim.keymap.set("i", l, r, opts or {}) end
local n = function(l, r, opts) vim.keymap.set("n", l, r, opts or {}) end

g.mapleader = " "
g.maplocalleader = ","

i("jk", "<esc>")

n("<bs>",      ":nohl<cr>")
n("*",         "g*")
n("-",         ":Ex<cr>")
n("<c-h>",     "<c-w><c-h>")
n("<c-l>",     "<c-w><c-l>")
n("<c-j>",     "<c-w><c-j>")
n("<c-k>",     "<c-w><c-k>")
n("<c-up>",    ":resize +2<cr>")
n("<c-down>",  ":resize -2<cr>")
n("<c-left>",  ":vertical resize -2<cr>")
n("<c-right>", ":vertical resize +2<cr>")
n("<S-h>",     ":bprevious<cr>")
n("<S-l>",     ":bnext<cr>")
n("s",         "<Plug>(leap)")
n("S",         "<Plug>(leap-from-window)")

n("]d", function () vim.diagnostic.goto_next {float=false} end)
n("[d", function () vim.diagnostic.goto_prev {float=false} end)

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local create_autocmd = vim.api.nvim_create_autocmd
local create_augroup = vim.api.nvim_create_augroup
local create_buf_augroup=function(name, buf) 
    local group=create_augroup(name, {clear=false}) 
    vim.api.nvim_clear_autocmds({group=group, buffer=buf})
    return group
end

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
    n("<esc>", ":Sayonara!<cr>",  opt)
    n("h",     "-",               opt)
    n("l",     "<cr>",            opt)
    n(".",     "gh",              opt)
    n("H",     "h",               opt)
  end,
})

------------------------------------------------------------
-- LSP
------------------------------------------------------------

create_autocmd("lspattach", {
  group = create_augroup("lsp-1", {}),
  callback = function(ev) 
    create_autocmd("cursorhold", {
      buffer = ev.buf,
      group = create_buf_augroup("lsp-2", ev.buf),
      callback = function(_)
        vim.diagnostic.open_float()
        return false
      end
    })
  end
})

------------------------------------------------------------
-- GO
------------------------------------------------------------

vim.lsp.enable('gopls')

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
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    -- { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
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
  local ns = vim.api.nvim_create_namespace "diagnostic"
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
    return old_show(ns, buf, ds, opt)
  end
  local new_hide = function (_ns, buf)
    return old_hide(ns, buf) 
  end
  vim.diagnostic.handlers.underline = {show=new_show, hide=new_hide}
end

create_autocmd("VimEnter", {
  group=create_augroup("diagnostic-1", {}),
  callback=patch_diagnostic_underline
})

local patch_open_float = function ()
  local old_open_float = vim.diagnostic.open_float
  local new_open_float = function(old_opts) 
    local ext_opts = {
      border = {"┌", "─", "┐", "│", "┘", "─", "└", "│"},
      focus = false, 
      scope = "line",
      header = "", 
      prefix = " ", 
      suffix = " "
    }
    local new_opts = vim.tbl_extend("force", old_opts or {}, ext_opts)
    bufno, win_id = old_open_float(new_opts)
    if win_id then
      local old_conf = vim.api.nvim_win_get_config(win_id)
      local ext_conf = {
        relative = "win",
        win = vim.api.nvim_get_current_win(),
        col = 999,
        row = 0,
      }
      local new_conf = vim.tbl_extend("force", old_conf, ext_conf)
      vim.api.nvim_win_set_config(win_id, new_conf)
    end
    return bufno, win_id
  end
  vim.diagnostic.open_float = new_open_float
end

create_autocmd("VimEnter", {
  group=create_augroup("diagnostic-2", {}),
  callback=patch_open_float
})



------------------------------------------------------------
-- COLOR
------------------------------------------------------------

local hl = function (group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local hl_clear = function() 
  for hlgroup, _ in pairs(vim.api.nvim_get_hl(0, {})) do
    if type(hlgroup) == "string" then
      hl(hlgroup, {fg="#101010", bg="#fefefe"})
    end
  end
end

local hl_set = function ()
  local red = "#AB0303"
  local green = "#167e18"
  local blue = "#001097"
  -- vim
  hl("normal",        {fg="#101010", bg="#fdfdfd"}) 
  hl("comment",       {fg="#9c9ea3"}) 
  hl("cursearch",     {bg="#faf2d8"})
  hl("endofbuffer",   {fg="#fefefe"})
  hl("floatborder",   {fg="#9c9c9c"})
  hl("incsearch",     {bg="#faf2d8"})
  hl("matchparen",    {bg="#e3eefd"})
  hl("pmenu",         {bg="#f0f0f0"})
  hl("pmenusel",      {bg="#dbdbdb"})
  hl("search",        {bg="#faf2d8"})
  hl("statusline",    {bg="#ebebeb"}) 
  hl("visual",        {bg="#e4effe"})
  hl("visualnos",     {bg="#e4effe"})
  hl("winseparator",  {fg="#e2e2e2"})
  -- code
  hl("@comment",      {fg="#9c9ea3"})
  -- lua
  hl("@string.lua",              {fg=green})
  hl("@string.escape.lua",       {fg=green})
  hl("@boolean.lua",             {fg="purple"})
  hl("@number.lua",              {fg=red})
  hl("@keyword.conditional.lua", {fg=blue})
  hl("@keyword.function.lua",    {fg=blue})
  hl("@keyword.lua",             {fg=blue})
  hl("@keyword.operator.lua",    {fg=blue})
  hl("@keyword.repeat.lua",      {fg=blue})
  hl("@keyword.return.lua",      {fg=blue})
  hl("@constructor.lua",         {fg="#3c3c45"})
  -- go
  -- leap
  hl("LeapLabelPrimary",         {bg="#fadffa"})
  -- diagnostic
  hl("DiagnosticUnderlineError", {bg="#fbe5e5"})
  hl("DiagnosticUnderlineWarn",  {bg="#fbe5e5"})
  hl("DiagnosticUnderlineInfo",  {bg="#fbe5e5"})
  hl("DiagnosticUnderlineHint",  {bg="#fbe5e5"}) 
  hl("DiagnosticUnnecessary",    {bg="#fbe5e5"}) 
  hl("DiagnosticDeprecated",     {bg="#fbe5e5"})
  hl("DiagnosticFloatingError",  {fg="#030303"})
end

hl_set()

local hl_augroup = create_augroup("HIGHLIGHT", {clear=true})

create_autocmd("colorscheme", {
  group=hl_augroup,
  pattern='default',
  callback=function () 
    hl_clear()
    hl_set()
  end,
})

vim.cmd("colorscheme default")
