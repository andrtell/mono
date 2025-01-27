(set vim.g.netrw_banner 0)
(set vim.g.netrw_list_hide "\\(^\\|\\s\\s\\)\\zs\\.\\S\\+")
(set vim.g.netrw_keepdir 0)

(local buffer-keys
	   [[:n "<ESC>" ":Sayonara!<CR>"]
		[:n "h" "-"]
		[:n "l" "<CR>"]
		[:n "<left>" "-"]
		[:n "<right>" "<CR>"]
		[:n "." "gh"]
		[:n "H" "u"]])

(fn set-keys []
  (each [_ [m l r] (ipairs buffer-keys)]
	(vim.keymap.set m l r {:silent true :buffer true :remap true})))

(local netrw-group 
	   (vim.api.nvim_create_augroup :netrw {:clear true}))

(vim.api.nvim_create_autocmd 
  ["FileType"] 
  {:pattern ["netrw"] 
   :group netrw-group 
   :callback set-keys})
