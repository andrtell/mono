(local options
       {:background "light" 
		:cursorline false
		:laststatus 3 
		:showcmd false
		:showmode false
		:signcolumn "yes:1"})

(each [key value (pairs options)]
  (tset vim.opt key value))

(set vim.o.statusline " %f %m%r %=| %{&filetype} | %4l | ")

(vim.cmd "colorscheme quiet")
