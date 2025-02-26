;
; Options
;

(local o {:ignorecase true
          :smartcase true
          :updatetime 250
          :timeoutlen 300
          :scrolloff 21
          :mouse "a"
          :breakindent true
          :laststatus 3
          :signcolumn "yes:1"
          :cursorline false
          :showcmd false
          :showmode false
          :shortmess "Ita"
          :gdefault true
          :swapfile false})

(each [k v (pairs o)]
  (tset vim.opt k v))

(vim.schedule (fn [] (set vim.opt.clipboard "unnamedplus")))

;
; Statusline
;

(set vim.o.statusline " %f %m%r %= %{&filetype} | %{&fenc} | %3l  ")

;
; Keys
;

(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

(fn goto-next [_] 
  (vim.diagnostic.goto_next {:float false}))

(fn goto-prev [_] 
  (vim.diagnostic.goto_prev {:float false}))

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
		     ["]g" goto-next] 
		     ["[g" goto-prev]
                     ["s" "<Plug>(leap)"]
                     ["S" "<Plug>(leap-from-window)"]]})

(local lsp-keys {:n [["gD" (fn [] (vim.lsp.buf.declaration))]
                     ["gd" (fn [] (vim.lsp.buf.definition))]]}) 

(local nrw-keys {:n [["<esc>" ":Sayonara!<CR>"]
                     ["h" "-"]
                     ["l" "<CR>"]
                     ["." "gh"]
                     ["H" "u"]]}) 

;
; Util
;

(fn map-keys [keys opt] 
  (each [m ks (pairs keys)]
   (each [_ k (ipairs ks)]
     (vim.keymap.set m (. k 1) (. k 2) opt))))

(map-keys vim-keys {:silent true})

;
; Colors
;

(set vim.o.background "light")

(each [hlgrp _ (pairs (vim.api.nvim_get_hl 0 {}))]
  (if (= "string" (type hlgrp))
     (vim.api.nvim_set_hl 0 hlgrp {:fg "#010101" :bg "#fefefe"}))) 
    
(local colors [["Search"       {:bg "#faefd8"}] 
               ["IncSearch"    {:bg "#faefd8"}]
               ["CurSearch"    {:bg "#f9edd8"}]
               ["Visual"       {:bg "#e3eefd"}]
               ["VisualNOS"    {:bg "#e3eefd"}]
               ;["MatchParen"   {:bg "#d5f5d5"}]
               ["MatchParen"   {:bg "#e3eefd"}]
               ["Pmenu"        {:bg "#f0f0f0"}]
               ["PmenuSel"     {:bg "#d9d9d9"}]
               ["StatusLine"   {:bg "#ebebeb"}] 
               ["WinSeparator" {:fg "#ebebeb"}]
               ["EndOfBuffer"  {:fg "#fefefe"}]
               ["Comment"      {:fg "#9c9ea3"}] 
               ["@comment"     {:fg "#9c9ea3"}]
               ["LeapLabelPrimary"         {:bg "#fadffa"}]
               ["DiagnosticUnderlineError" {:bg "#fbe5e5"}]
               ["DiagnosticUnderlineWarn"  {:bg "#fbe5e5"}] 
               ["DiagnosticUnderlineInfo"  {:bg "#fbe5e5"}] 
               ["DiagnosticUnderlineHint"  {:bg "#fbe5e5"}] 
               ["DiagnosticUnnecessary"    {:bg "#fbe5e5"}] 
               ["DiagnosticDeprecated"     {:bg "#fbe5e5"}]
	       ["DiagnosticFloatingError" {:fg "#030303"}]
	       ["FloatBorder" {:fg "#9c9c9c"}]])

(each [_ hl (ipairs colors)]
  (vim.api.nvim_set_hl 0 (. hl 1) (. hl 2)))

;
; Util
;

(fn group [name]
  (vim.api.nvim_create_augroup name {:clear true})) 

(fn buffer-group [bufnr name]
  (let [group (vim.api.nvim_create_augroup name {:clear false})]
   (vim.api.nvim_clear_autocmds {:group group :buffer bufnr})
   group))

;
; Netrw
;
  
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

;
; Diagnostic
;

(vim.diagnostic.config {:virtual_text false})

(vim.fn.sign_define "DiagnosticSignWarn" {:text ""})
(vim.fn.sign_define "DiagnosticSignError" {:text ""})

(let [ns (vim.api.nvim_create_namespace "diagnostics") 
      show-0 vim.diagnostic.handlers.underline.show
      hide-0 vim.diagnostic.handlers.underline.hide]
  (set vim.diagnostic.handlers.underline
       {:show
        (fn [_ bufnr ds opt]
          (each [_ d (ipairs ds)]
           (if (= d.col d.end_col) 
             (let [lastcol (-> (vim.fn.getline ".") (vim.fn.strlen))]
                (if (= d.col lastcol) 
                  (set d.col 0)
                  (set d.end_col lastcol))))
           (show-0 ns bufnr ds opt)))
        :hide
        (fn [_ bufnr] (hide-0 ns bufnr))}))

(fn open-float [_]
  (let [(buf-nr win-id) 
	(vim.diagnostic.open_float {:focus false 
				    :scope "line"
				    :border ["┌" "─" "┐" "│" "┘" "─" "└" "│"]
				    :header "" 
				    :prefix " "
				    :suffix " "})]
    (if win-id
	(let [config-0 (vim.api.nvim_win_get_config win-id)
	      config-1 (vim.tbl_extend "force" config-0 {:relative "win"
				       			 :win (vim.api.nvim_get_current_win)
							 :row 0
							 :col 999})]
    	  (vim.api.nvim_win_set_config win-id config-1)))))

(vim.api.nvim_create_autocmd 
  "FileType" 
  {:group (group "diagnostic-go-0")
   :pattern ["go" "gomod" "gowork" "gotmpl"]
   :callback 
   (fn [ev] 
     (vim.api.nvim_create_autocmd
       ["CursorHold"]
       {:group (buffer-group ev.buf "diagnostic-go-buf-0")
        :buffer ev.buf
	:callback (fn [] (open-float) false)}))})

;
; LSP
;

(vim.api.nvim_create_autocmd 
  "LspAttach" 
  {:group (group "lsp-1")
   :callback (fn [_] (map-keys lsp-keys {:silent true 
                                         :buffer true}))})

(fn organize-imports [buf] 
  (let [params-0 (vim.lsp.util.make_range_params)
	params-1 (vim.tbl_extend "force" params-0 {:context {:diagnostic {} 
				                             :only ["source.organizeImports"]}})
        results (vim.lsp.buf_request_sync buf "textDocument/codeAction" params-1 500)]
    (if results 
	(let [result-1 (. results 1)]
	  (if result-1.result
	      (let [action-1 (. result-1.result 1)] 
		(vim.lsp.util.apply_workspace_edit action-1.edit "utf-16")))))))

(vim.api.nvim_create_autocmd 
  "LspAttach" 
  {:group (group "lsp-2")
   :callback 
   (fn [ev] 
    (vim.api.nvim_create_autocmd 
     "BufWritePre"
     {:group (buffer-group ev.buf "lsp-format")
      :buffer ev.buf
      :callback (fn [] (if vim.bo.modified 
			   (vim.lsp.buf.format)))})
    (vim.api.nvim_create_autocmd 
     "BufWritePre"
     {:group (buffer-group ev.buf "lsp-imports")
      :buffer ev.buf
      :callback (fn [] (if vim.bo.modified 
			   (organize-imports ev.buf)))}))})

(let [fun vim.lsp.util.open_floating_preview]
  (tset vim.lsp.util 
	:open_floating_preview
	(fn [contents syntax opts & rest]
	  (let [opts-0 (or opts {})
		border ["┌" "─" "┐" "│" "┘" "─" "└" "│"]
		opts-1 (vim.tbl_extend "force" opts-0 {:border border
				                       :max_width 80})]
	    (fun contents syntax opts-1)))))

;
; Go
;

(vim.api.nvim_create_autocmd 
  "FileType" 
  {:group (group "lsp-gopls")
   :pattern ["go" "gomod" "gowork" "gotmpl"]
   :callback 
   (fn [ev] 
     (vim.lsp.start 
       {:cmd ["gopls"]
        :name "gopls"
        :single_file_support true
        :root_dir (vim.fs.root ev.buf ["go.work" "go.mod" ".git"])}))})


