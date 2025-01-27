(fn file-exists? [path] (vim.uv.fs_stat path))

(fn shell-error? [] (not (= vim.v.shell_error 0)))

(fn die [error-message] (io.write error-message) (os.exit 1))

(fn clone-lazy [target-dir]
	(let [cmd ["git" 
			   "clone"
			   "--filter=blob:none"
			   "--branch=stable"
			   "https://github.com/folke/lazy.nvim.git"
			   target-dir]]
	  (vim.fn.system cmd)))

(fn clone-lazy-or-die [target-dir]
	(let [out (clone-lazy target-dir)
	      msg (out:gsub "%s+" " ")]
	  (if (shell-error?) (die msg))))
 
(fn install-lazy [packages-dir] 
  (let [lazy-dir (.. packages-dir "/lazy.nvim")] 
    (if (not (file-exists? lazy-dir))
		(clone-lazy-or-die lazy-dir)) 
    (vim.opt.rtp:prepend lazy-dir)))

(local packages-dir (.. (vim.fn.stdpath :config) "/packages"))

(install-lazy packages-dir)

(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

(local config {:root packages-dir
	   		   :lockfile (.. packages-dir "/lazy-lock.json")
			   :spec [{ 1 "Olical/nfnl" :ft "fennel" } {:import "spec"}]
			   :checker {:enabled false }
			   :install {:colorscheme [ "binary" ] }})

(let [lazy (require :lazy)] (lazy.setup config))

(require :options)
(require :keymaps)
(require :statusline)
(require :colors)
(require :netrw)
(require :diagnostic)
