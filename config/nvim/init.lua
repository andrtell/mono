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
o.background = "light"
o.cursorline = false
o.gdefault = true
o.laststatus = 3
o.mouse = "a"
o.number = false
o.scrolloff = 21
o.shortmess = "Ita"
o.showcmd = false
o.showmode = false
o.signcolumn = "yes:1"
o.smartcase = true
o.swapfile = false
o.timeoutlen = 300
o.updatetime = 250
o.statusline=" %f %m%r %= %{&filetype} | %n | %{&fenc} | %3l : %2c  "
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

n("<bs>", ":nohl<cr>")
n("*", "g*")
n("-", ":Ex<cr>")
n("<c-h>", "<c-w><c-h>")
n("<c-l>", "<c-w><c-l>")
n("<c-j>", "<c-w><c-j>")
n("<c-k>", "<c-w><c-k>")
n("<c-up>", ":resize +2<cr>")
n("<c-down>", ":resize -2<cr>")
n("<c-left>", ":vertical resize -2<cr>")
n("<c-right>", ":vertical resize +2<cr>")
n("<S-h>", ":bprevious<cr>")
n("<S-l>", ":bnext<cr>")
n("]g", function () vim.diagnostic.goto_next {float=false} end)
n("[g", function () vim.diagnostic.goto_prev {float=false} end)
n("s", "<Plug>(leap)")
n("S", "<Plug>(leap-from-window)")

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local create_autocmd = vim.api.nvim_create_autocmd
local clear_autocmds = vim.api.nvim_clear_autocmds
local create_augroup = vim.api.nvim_create_augroup

local create_buf_augroup=function(name, buf) 
    local group=create_augroup(name, {clear=false}) 
    clear_autocmds({group=group, buffer=buf})
    return group
end

------------------------------------------------------------
-- NETRW
------------------------------------------------------------

g.netrw_banner = 0
g.netrw_keepdir = 0
g.netrw_list_hide="\\(^\\|\\s\\s\\)\\zs\\.\\S\\+"

local netrw_keys = function () 
  local opt = { silent=true, buffer=true, remap=true }
  n("<esc>", ":Sayonara!<cr>", opt)
  n("h", "-", opt)
  n("l", "<cr>", opt)
  n(".", "gh", opt)
  n("H", "h", opt)
end

local netrw_group = create_augroup("netrw-0", {clear=true})

create_autocmd("filetype", {
  pattern="netrw",
  group=netrw_group,
  callback=function ()
    netrw_keys()
  end,
})

------------------------------------------------------------
-- DIAGNOSTIC
------------------------------------------------------------

vim.fn.sign_define("DiagnosticSignWarn", {text=""})
vim.fn.sign_define("DiagnosticSignError", {text=""})

vim.diagnostic.config {virtual_text=false}

local patch_underline = function () 
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

local patch_open_float = function ()
  local old_open_float = vim.diagnostic.open_float
  local new_open_float = function(old_opts) 
    local ext_opts = {
      border = {"┌", "─", "┐", "│", "┘", "─", "└", "│"},
      focus = false, header = "", prefix = " ", scope = "line", suffix = " "
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

local diagnostic_group = create_augroup("DIAGNOSTIC-0", {clear=true}) 

create_autocmd("VimEnter", {
  group=diagnostic_group,
  callback=function ()
    patch_underline()
    patch_open_float()
  end
})

------------------------------------------------------------
-- LSP
------------------------------------------------------------

local lsp_keys = function()
    local opt = { silent=true, buffer=true }
    n("gD", function () vim.lsp.buf.declaration() end)
    n("gd", function () vim.lsp.buf.definition() end)
    return false
end

local lsp_format_buffer = function()
    if vim.bo.modified then
      vim.lsp.buf.format()
    end
end

local lsp_setup_format_buffer = function(buf)
  local group = create_buf_augroup("LSP-1", buf)
  create_autocmd("bufwrite", {
    buffer = buf,
    group = group,
    callback = function()
      lsp_format_buffer()
    end
  })
end

local lsp_organize_imports_buffer = function(buf)
  if not vim.bo.modified then
    return
  end
  local params0 = vim.lsp.util.make_range_params()
  local patch = {context={diagnostic={}, only={"source.organizeImports"}}}
  local params1 = vim.tbl_extend("force", params0 or {}, patch) 
  local timeout_ms = 500
  local response = vim.lsp.buf_request_sync(
    buf, 
    "textDocument/codeAction", 
    params1, 
    timeout_ms
  )
  for _, result_list in ipairs(response or {}) do
    for _, result in ipairs(result_list or {}) do 
      vim.lsp.util.apply_workspace_edit(result.edit, "utf-16")
    end
  end
end

local lsp_setup_organize_imports_buffer = function(buf)
  local group = create_buf_augroup("LSP-2", buf)
  create_autocmd("bufwrite", {
    buffer = buf,
    group = group,
    callback = function(ev)
      lsp_organize_imports_buffer(ev.buf)
    end
  })
end

local lsp_setup_show_float = function(buf)
  local group = create_buf_augroup("LSP-3", buf)
  create_autocmd("cursorhold", {
    buffer = buf,
    group = group,
    callback = function(ev)
      vim.diagnostic.open_float()
      return false
    end
  })
end

local lsp_group = create_augroup("LSP-0", {clear=true})

create_autocmd("lspattach", {
  group=lsp_group,
  callback = function(ev) 
    lsp_keys()
    lsp_setup_format_buffer(ev.buf)
    lsp_setup_organize_imports_buffer(ev.buf)
    lsp_setup_show_float(ev.buf)
  end
})

local patch_open_floating_preview = function()
  old_open_floating_preview = vim.lsp.util.open_floating_preview
  new_open_floating_preview = function(contents, syntax, opts0, ...) 
    patch = {
      border = {"┌","─", "┐", "│", "┘", "─", "└", "│"},
      max_width = 100,
      focusable=true
    }
    opts1 = vim.tbl_extend("force", opts0 or {}, patch)
    return old_open_floating_preview(contents, syntax, opts1, unpack(arg))
  end
  vim.lsp.util.open_floating_preview=new_open_floating_preview
end

create_autocmd("VimEnter", {
  group=lsp_group,
  callback=function ()
    patch_open_floating_preview()
  end
})

------------------------------------------------------------
-- GOLANG
------------------------------------------------------------

local golang_group = create_augroup("GOLANG-0", {clear=true})

create_autocmd("filetype", {
  pattern={"go", "gomod", "gowork", "gotmpl"},
  group=golang_group,
  callback=function (ev) 
    vim.lsp.start({
      cmd={"gopls"},
      name="gopls",
      single_file_support=true,
      root_dir=vim.fs.root(ev.buf, {"go.work", "go.mod", ".git"})
    })
  end
})

------------------------------------------------------------
-- TREESITTER
------------------------------------------------------------

require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "bash", "dockerfile", "json", "lua", "python", "sql", "yaml", 
    "go", "gomod", "gowork", "gotmpl"
  },
  auto_install=true,
  highlight={enable=true}
}

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
  local red = "#B20000"
  local green = "#188120"
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

-- hl_set()

local hl_augroup = create_augroup("HL", {clear=true})

create_autocmd("colorscheme", {
  group=hl_augroup,
  pattern='default',
  callback=function () 
    hl_clear()
    hl_set()
  end,
})

vim.cmd("colorscheme default")
