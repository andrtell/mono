(local options
       {:ignorecase true 
       	:smartcase true 
	:laststatus 3
	:updatetime 250
	:timeoutlen 300
	:cursorline false
	:scrolloff 10
	:mouse "a"
	:showmode false
	:breakindent true
	:tabstop 4
	:shiftwidth 4})

(each [key value (pairs options)]
  (tset vim.opt key value))

(vim.schedule (fn [] (set vim.opt.clipboard "unnamedplus")))
