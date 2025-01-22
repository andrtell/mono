{1 "neovim/nvim-lspconfig"
 :config (fn [] 
		   (let [lspconfig (require "lspconfig")]
			 (lspconfig.ocamllsp.setup {})))}

; require'lspconfig'.ocamllsp.setup{}
