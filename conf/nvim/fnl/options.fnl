(local options
       {:ignorecase true 
       	:smartcase true
		:updatetime 250
		:timeoutlen 300
		:scrolloff 10
		:mouse "a"
		:breakindent true
		:tabstop 4
		:shiftwidth 4})

(each [key value (pairs options)]
  (tset vim.opt key value))

(vim.schedule (fn [] (set vim.opt.clipboard "unnamedplus")))
