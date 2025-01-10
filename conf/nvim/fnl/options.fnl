(local options
       {:ignorecase true
	   :smartcase true
	   :updatetime 250
	   :timeoutlen 300
	   :scrolloff 10
	   :mouse "a" 
	   :breakindent true 
	   :tabstop 4
	   :shiftwidth 4
	   ;; ui
	   :background "light"
	   :cursorline false
	   :laststatus 3
	   :showcmd false
	   :showmode false
	   :signcolumn "yes:1"})

(each [key value (pairs options)]
  (tset vim.opt key value))

(vim.schedule (fn [] (set vim.opt.clipboard "unnamedplus")))

(set vim.o.statusline " %f %m%r %= %{&filetype} | %3l  ")

(vim.cmd "colorscheme quiet")
