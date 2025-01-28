(fn get-bufnr [] 
  (vim.api.nvim_get_current_buf))

(fn new-auto-grp [name bufnr]
  (vim.api.nvim_create_augroup name {:clear false}))

(fn clr-auto-grp [gid bufnr]
  (vim.api.nvim_clear_autocmds {:group gid
							    :buffer bufnr}))

(fn new-auto-cmd [ev gid bufnr cb]
  (vim.api.nvim_create_autocmd ev {:group gid 
							   	   :buffer bufnr
								   :callback cb}))

(fn result-handler [err result ctx]
  (case [err result ctx]
	[nil result ctx] (print "OK")
	[err _ _] (print "error")))

(fn event-handler [args]
  (let [method "textDocument/formatting"]
	(each [_ client (ipairs (vim.lsp.get_clients {:bufnr args.buf}))]
	  (if (client.supports_method method {:bufnr args.buf})
	   (client.request method (vim.lsp.util.make_formatting_params) result-handler args.buf)))))

(fn on-attach [client bufnr]
  (let [gid (new-auto-grp "lsp-format" bufnr)]
	(clr-auto-grp gid bufnr)
	(new-auto-cmd "BufWritePost" gid bufnr event-handler)))

{1 "neovim/nvim-lspconfig"
 :config (fn [] (let [lspconfig (require "lspconfig")] 
				  (lspconfig.gopls.setup {:on_attach on-attach})))}
