(local keys
	   [
		;; VIM
		[:i "jk" "<ESC>"] 
		[:n "<C-h>" "<C-w><C-h>"]
		[:n "<C-l>" "<C-w><C-l>"]
		[:n "<C-j>" "<C-w><C-j>"]
		[:n "<C-k>" "<C-w><C-k>"]
		[:n "-" ":Ex<CR>"]
		;; LEAP
		[:n "s" "<Plug>(leap)"]
		[:n "S" "<Plug>(leap-from-window)"]
		[[:x :o] "s" "<Plug>(leap-forward)"]
		[[:x :o] "S" "<Plug>(leap-backward)"]
		])

(each [_ [m l r] (ipairs keys)]
  (vim.keymap.set m l r))
