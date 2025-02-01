; Options

(local o {:ignorecase true
          :smartcase true
          :updatetime 250
          :timeoutlen 300
          :scrolloff 10
          :mouse "a"
          :breakindent true
          :laststatus 3
          :signcolumn "yes:1"
          :cursorline false
          :showcmd false
          :showmode false
          :shortmess "Ita"
          :swapfile false})

(each [k v (pairs o)]
  (tset vim.opt k v))

(vim.schedule (fn [] (set vim.opt.clipboard "unnamedplus")))

; Statusline

(set vim.o.statusline " %f %m%r %= %{&filetype} | %{&fenc} | %3l  ")

; Keys

(local vim-keys {:i [["jk" "<esc>"]]
                 :n [["<bs>" ":nohl<cr>"]
                     ["*" "g*"]
                     ["-" ":Ex<cr>"]
                     ["<c-h>" "<c-w><c-h>"]
                     ["<c-l>" "<c-w><c-l>"]
                     ["<c-j>" "<c-w><c-j>"] 
                     ["<c-k>" "<c-w><c-k>"]
                     ["<c-up>" ":resize +2<cr>"]
                     ["<c-down>" ":resize -2<cr>"]
                     ["<c-left>" ":vertical resize -2<cr>"]
                     ["<c-right>" ":vertical resize +2<cr>"]
                     ["<S-h>" ":bprevious<cr>"]
                     ["<S-l>" ":bnext<cr>"]
                     ["s" "<Plug>(leap)"]
                     ["S" "<Plug>(leap-from-window)"]]})

(local lsp-keys {:n [["gD" (fn [] (vim.lsp.buf.declaration))]
                     ["gd" (fn [] (vim.lsp.buf.definition))]]}) 

(local nrw-keys {:n [["<esc>" ":Sayonara!<CR>"]
                     ["h" "-"]
                     ["l" "<CR>"]
                     ["." "gh"]
                     ["H" "u"]]}) 

; Util

(fn map-keys [keys opt] 
  (each [m ks (pairs keys)]
   (each [_ k (ipairs ks)]
     (vim.keymap.set m (. k 1) (. k 2) opt))))

(map-keys vim-keys {:silent true})

; Colors

(set vim.o.background "light")

(each [hlgrp _ (pairs (vim.api.nvim_get_hl 0 {}))]
  (if (= "string" (type hlgrp))
     (vim.api.nvim_set_hl 0 hlgrp {:fg "#030303" :bg "#fefefe"}))) 
    
(local colors [["Search"       {:bg "#f9edd7"}] 
               ["IncSearch"    {:bg "#f9edd7"}]
               ["CurSearch"    {:bg "#f9edd7"}]
               ["Visual"       {:bg "#e2eafb"}]
               ["VisualNOS"    {:bg "#e2eafb"}]
               ["MatchParen"   {:bg "#fbe4e4"}]
               ["Pmenu"        {:bg "#f0f0f0"}]
               ["PmenuSel"     {:bg "#d9d9d9"}]
               ["StatusLine"   {:bg "#ebebeb"}] 
               ["WinSeparator" {:fg "#ebebeb"}]
               ["EndOfBuffer"  {:fg "#fefefe"}]
               ["Comment"      {:fg "#9d9fa4"}] 
               ["@comment"     {:fg "#9d9fa4"}]
               ["LeapLabelPrimary"         {:bg "#fbe0fb"}]
               ["DiagnosticUnderlineError" {:bg "#fbe4e4"}]
               ["DiagnosticUnderlineWarn"  {:bg "#fbe4e4"}] 
               ["DiagnosticUnderlineInfo"  {:bg "#fbe4e4"}] 
               ["DiagnosticUnderlineHint"  {:bg "#fbe4e4"}] 
               ["DiagnosticUnnecessary"    {:bg "#fbe4e4"}] 
               ["DiagnosticDeprecated"     {:bg "#fbe4e4"}]])
     
(each [_ hl (ipairs colors)]
  (vim.api.nvim_set_hl 0 (. hl 1) (. hl 2)))

; Util

(fn group [name]
  (vim.api.nvim_create_augroup name {:clear true})) 

(fn buffer-group [bufnr name]
  (let [group (vim.api.nvim_create_augroup name {:clear false})]
   (vim.api.nvim_clear_autocmds {:group group :buffer bufnr})
   group))

; Netrw
  
(set vim.g.netrw_banner 0)
(set vim.g.netrw_list_hide "\\(^\\|\\s\\s\\)\\zs\\.\\S\\+")
(set vim.g.netrw_keepdir 0)

(vim.api.nvim_create_autocmd 
  "FileType" 
  {:group (group "netrw")
   :pattern "netrw"
   :callback (fn [_] (map-keys nrw-keys {:silent true 
                                         :buffer true 
                                         :remap true}))})

; Diagnostic

(vim.fn.sign_define "DiagnosticSignWarn" {:text ""})
(vim.fn.sign_define "DiagnosticSignError" {:text ""})

(let [ns (vim.api.nvim_create_namespace "dns") 
      show_0 vim.diagnostic.handlers.underline.show
      hide_0 vim.diagnostic.handlers.underline.hide]
  (set vim.diagnostic.handlers.underline
       {:show
        (fn [_ bufnr ds opt]
          (each [_ d (ipairs ds)]
           (if (= d.col d.end_col) 
             (let [lastcol (-> (vim.fn.getline ".") (vim.fn.strlen))]
                (if (= d.col lastcol) 
                  (set d.col 0)
                  (set d.end_col lastcol))))
           (show_0 ns bufnr ds opt)))
        :hide
        (fn [_ bufnr] (hide_0 ns bufnr))}))

; LSP

(vim.api.nvim_create_autocmd 
  "FileType" 
  {:group (group "gopls")
   :pattern ["go" "gomod" "gowork" "gotmpl"]
   :callback 
   (fn [ev] 
     (vim.lsp.start 
       {:cmd ["gopls"]
        :name "gopls"
        :single_file_support true
        :root_dir (vim.fs.root ev.buf ["go.work" "go.mod" ".git"])}))})

(vim.api.nvim_create_autocmd 
  "LspAttach" 
  {:group (group "lsp-1")
   :callback (fn [_] (map-keys lsp-keys {:silent true 
                                         :buffer true}))})

(vim.api.nvim_create_autocmd 
  "LspAttach" 
  {:group (group "lsp-2")
   :callback 
   (fn [ev] 
    (vim.api.nvim_create_autocmd 
     "BufWritePre"
     {:group (buffer-group ev.buf "lsp-format")
      :buffer ev.buf
      :callback (fn [] (if vim.bo.modified (vim.lsp.buf.format)))}))}) 
