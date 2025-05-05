------------------------------------------------------------
-- ╔╗╔╔═╗╔═╗╦  ╦╦╔╦╗
-- ║║║║╣ ║ ║╚╗╔╝║║║║
-- ╝╚╝╚═╝╚═╝ ╚╝ ╩╩ ╩
------------------------------------------------------------                 

g = vim.g
o = vim.opt

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

i = function(l, r, opts) vim.keymap.set("i", l, r, opts or {}) end
n = function(l, r, opts) vim.keymap.set("n", l, r, opts or {}) end

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

create_autocmd = vim.api.nvim_create_autocmd
clear_autocmds = vim.api.nvim_clear_autocmds
create_augroup = vim.api.nvim_create_augroup

create_buf_augroup=function(name, buf) 
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

netrw_keys = function () 
  local opt = { silent=true, buffer=true, remap=true }
  n("<esc>", ":Sayonara!<cr>", opt)
  n("h", "-", opt)
  n("l", "<cr>", opt)
  n(".", "gh", opt)
  n("H", "h", opt)
end

netrw_group = create_augroup("netrw-0", {clear=true})

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

patch_diagnostic_underline = function () 
  local ns = vim.api.nvim_create_namespace "diagnostic"
  local show0 = vim.diagnostic.handlers.underline.show
  local show1 = function (_ns, buf, ds, opt)
    for _, d in ipairs(ds) do
      if d.col == d.end_col then
        local last_col = vim.fn.strlen(vim.fn.getline("."))
        if d.col == last_col then
          d.col = 0
          d.end_col = last_col
        end
        show0(ns, buf, ds, opt)
      end
    end
  end
  local hide0 = vim.diagnostic.handlers.underline.hide
  local hide1 = function ()
    hide0(ns, buf) 
  end
  vim.diagnostic.handlers.underline = {show=show1, hide=hide1}
end

patch_diagnostic_open_float = function ()
  local open_float0 = vim.diagnostic.open_float 
  local open_float1 = function(_opts) 
    local opts = {
      border = {"┌", "─", "┐", "│", "┘", "─", "└", "│"},
      focus = false,
      header = "" ,
      prefix = " ",
      scope = "line",
      suffix = " "
    }
    local bufnr, win_id = open_float0(opts)
    if win_id then
      local conf0 = vim.api.nvim_win_get_config(win_id)
      local patch = {
        relative = "win",
        win = vim.api.nvim_get_current_win(),
        col = 999,
        row = 0,
      }
      local conf1 = vim.tbl_extend("force", conf0, patch)
      vim.api.nvim_win_set_config(win, conf1)
    end
  end
  vim.diagnostic.open_float = open_float1
end

diagnostic_group = create_augroup("DIAGNOSTIC-0", {clear=true}) 

create_autocmd("VimEnter", {
  group=diagnostic_group,
  callback=function ()
    patch_diagnostic_underline()
    patch_diagnostic_open_float()
  end
})

------------------------------------------------------------
-- LSP
------------------------------------------------------------

lsp_keys = function()
    local opt = { silent=true, buffer=true }
    n("gD", function () vim.lsp.buf.declaration() end)
    n("gd", function () vim.lsp.buf.definition() end)
    return false
end

lsp_format_buffer = function()
    if vim.bo.modified then
      vim.lsp.buf_format()
    end
end

lsp_setup_format_buffer = function(buf)
  local group = create_buf_augroup("LSP-1", buf)
  create_autocmd("bufprewrite", {
    buffer = buf,
    group = group,
    callback = lsp_format_buffer,
  })
end

lsp_organize_imports_buffer = function(buf)
  if not vim.bo.modified then
    return
  end
  local params0 = vim.lsp.util.make_range_params()
  local patch = {context={diagnostic={}, only={"source.organizeImports"}}}
  local params1 = vim.tbl_extend("force", params0, patch) 
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

lsp_setup_organize_imports_buffer = function(buf)
  local group = create_buf_augroup("LSP-2", buf)
  create_autocmd("bufprewrite", {
    buffer = buf,
    group = group,
    callback = lsp_organize_imports_buffer
  })
end

lsp_group = create_augroup("LSP-0", {clear=true})

create_autocmd("lspattach", {
  group=lsp_group,
  callback=function (ev) 
    lsp_keys()
    lsp_setup_format_buffer(ev.buf)
    lsp_setup_organize_imports_buffer(ev.buf)
  end
})

------------------------------------------------------------
-- GOLANG
------------------------------------------------------------

golang_group = create_augroup("GOLANG-0", {clear=true})

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

hl = function (group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

hl_clear = function() 
  for hlgroup, _ in pairs(vim.api.nvim_get_hl(0, {})) do
    if type(hlgroup) == "string" then
      hl(hlgroup, {fg="#101010", bg="#fefefe"})
    end
  end
end

hl_set = function ()
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
  hl("visual",        {bg="#eff0f1"})
  hl("visualnos",     {bg="#e3eefd"})
  hl("winseparator",  {fg="#e2e2e2"})
  -- code
  hl("@comment",      {fg="#9c9ea3"})
  hl("@string",      {fg=green})
  -- lua
  -- hl("@string.lua",              {fg="green"})
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

hl_augroup = create_augroup("HL", {clear=true})

create_autocmd("colorscheme", {
  group=hl_augroup,
  pattern='default',
  callback=function () 
    hl_clear()
    hl_set()
  end,
})

vim.cmd("colorscheme default")
