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

local imap = function(l, r, opts)
  vim.keymap.set("i", l, r, opts or {}) 
end

local nmap = function(l, r, opts) 
  vim.keymap.set("n", l, r, opts or {}) 
end

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

do
  local function set_snippet_jump(direction, key)
    vim.keymap.set({ 'i', 's' }, key, function()
      if vim.snippet.active({ direction = direction }) then
        return string.format('<Cmd>lua vim.snippet.jump(%d)<CR>', direction)
      else
        return key
      end
    end, {
      desc = 'vim.snippet.jump if active, otherwise ' .. key,
      expr = true,
      silent = true,
    })
  end

  set_snippet_jump(1, '<CR>')
  set_snippet_jump(-1, '<S-CR>')
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

    nmap("<esc>", ":Sayonara!<cr>",  opt)
    nmap("h",     "-",               opt)
    nmap("l",     "<cr>",            opt)
    nmap(".",     "gh",              opt)
    nmap("H",     "h",               opt)

    hi("CursorLine", {bg="#efefef"})
    hi("NetrwDir", {bg="none"})
    hi("NetrwExe", {bg="none"})
    hi("NetrwClassify", {fg="#008080"})
  end,
})

------------------------------------------------------------
-- LSP
------------------------------------------------------------

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    -- delay update diagnostics
    update_in_insert = false,
  }
)

------------------------------------------------------------
-- GO
------------------------------------------------------------

do
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  vim.lsp.config('gopls', {capabilities = capabilites})
  vim.lsp.enable('gopls')

  local group = create_augroup("go-1", {})

  local callback = function ()
    nmap("<leader>i", "<Plug>(go-info)")
    nmap("<leader>r", "<Plug>(go-run)")
  end

  create_autocmd("BufEnter", {
    group=group, 
    pattern="*.go", 
    callback = callback
  })
end

------------------------------------------------------------
-- TINY INLINE
------------------------------------------------------------
do
  local signs = {
    left = "",
    right = "",
    diag = "",
    arrow = " ",
    up_arrow = "",
    vertical = " ",
    vertical_end = " ",
  }

  require('tiny-inline-diagnostic').setup({signs = signs})
end

------------------------------------------------------------
-- TREESITTER
------------------------------------------------------------

do
  local ensure_installed = {
      "bash", "dockerfile", "json", "lua", "python", "sql", "yaml", 
      "go", "gomod", "gowork", "gotmpl"
  }

  require('nvim-treesitter.configs').setup {
    auto_install=true,
    ensure_installed = ensure_installed,
    highlight={enable=true}
  }
end

------------------------------------------------------------
-- LuaSnip
------------------------------------------------------------

do
  local ls = require("luasnip")
  ls.setup()
  local s = ls.snippet
  local t = ls.text_node
  local i = ls.insert_node

  ls.add_snippets("go", {
    s("hello", {
      t('x := 1')
    })
  })
end

------------------------------------------------------------
-- CMP
------------------------------------------------------------

do

  local luasnip = require('luasnip')

  local cmp = require('cmp')

  local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
  end

  local snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  }

  local sources = cmp.config.sources(
    {{ name = 'nvim_lsp' }, { name = 'luasnip' }}, 
    {{ name = 'buffer' }}
  )

  local completion = {
    autocomplete = false,
    -- completeopt = 'menu,menuone,noselect'
  }

  local formatting = {
    expandable_indicator = false,
    fields = {"abbr"},
  }

  local window = {
    completion = cmp.config.window.bordered({
      winhighlight = 'Normal:Pmenu,FloatBorder:FloatBoarder,CursorLine:PmenuSel,Search:None',
      border={""},
    }),
    documentation = cmp.config.disable
  }

  local mapping = {
    ['<C-n']  = cmp.config.disable,
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>']  = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          if luasnip.expandable() then
            luasnip.expand()
          else
            cmp.confirm({select = true})
          end
        else
          fallback()
        end
      end
    ),
    ["<S-Tab>"] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, 
      { "i", "s" }
    ),
    ['<Tab>'] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          if #cmp.get_entries() == 1 then
            cmp.confirm({ select = true })
          else
            cmp.select_next_item()
          end
        elseif luasnip.locally_jumpable(1) then
          luasnip.jump(1)
        elseif luasnip.expandable() then
          luasnip.expand()
        elseif has_words_before() then
          cmp.complete()
          if #cmp.get_entries() == 1 then
            cmp.confirm({ select = true })
          else
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
          end
        else
          fallback()
        end
      end, 
      { "i", "s" }
    ),
  }

  cmp.setup({
    snippet = snippet,
    mapping = mapping,
    sources = sources,    
    completion = completion,
    preselect = cmp.PreselectMode.None,
    formatting = formatting,
    window = window
  })
end

------------------------------------------------------------
-- DIAGNOSTIC
------------------------------------------------------------

do
  local signs = { 
    text = { 
      [vim.diagnostic.severity.ERROR] = "", 
      [vim.diagnostic.severity.WARN] = "" 
    }
  }

  vim.diagnostic.config {
    signs = signs,
    virtual_text=false,
  }

  local patch = function (...) 
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

  local group = create_augroup("diagnostic", {})

  create_autocmd("VimEnter", {
    group=group,
    callback=patch
  })
end

------------------------------------------------------------
-- COLOR
------------------------------------------------------------

do
  local colors = function() 

    for hlgroup, _ in pairs(vim.api.nvim_get_hl(0, {})) do
      if type(hlgroup) == "string" then
        hi(hlgroup, {fg="#101010", bg="#fefefe"})
      end
    end

    local red_fg = "#A90303"
    local green_fg = "#107020"
    local blue_fg = "#002282"

    hi("normal",        {fg="#101010", bg="#fefefe"}) 
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

    hi("SnippetTabStop", {bg="#faf2d8"}) 

    hi("TinyInlineDiagnosticVirtualTextError", {bg="#f0f0f1"})
    hi("TinyInlineDiagnosticVirtualTextWarn", {bg="#f0f0f1"})
    hi("TinyInlineDiagnosticVirtualTextHint", {bg="#f0f0f1"})
    hi("TinyInlineDiagnosticVirtualTextArrow", {fg="#efeff1"})

    hi("LeapLabelPrimary",         {bg="#fadffa"})

    hi("DiagnosticUnderlineError", {bg="#fce5e5"})
    hi("DiagnosticUnderlineWarn",  {bg="#fbe5e5"})
    hi("DiagnosticUnderlineInfo",  {bg="#fbe5e5"})
    hi("DiagnosticUnderlineHint",  {bg="#fbe5e5"}) 
    hi("DiagnosticUnnecessary",    {bg="#fbe5e5"}) 
    hi("DiagnosticDeprecated",     {bg="#fbe5e5"})
    hi("DiagnosticFloatingError",  {fg="#030303"})
    hi("DiagnosticError",          {bg="#fbe5e5"})
    hi("DiagnosticWarn",           {bg="#fbe5e5"})

  end

  local group = create_augroup("HIGHLIGHT", {})

  create_autocmd("colorscheme", {
    group=group,
    pattern='default',
    callback=colors
  })

  vim.cmd("colorscheme default")
end
