;(fn event-handler [args]
;  (let [buffer-id args.buf] 
;	(each [_ client (ipairs (vim.lsp.get_clients {:bufnr args.buf}))]
;	 (if (client.supports_method "textDocument/formatting" {:bufnr buffer-id})
;	  (let [params (vim.lsp.util.make_formatting_params)]
;		(client.request "textDocument/formatting" params request-handler buffer-id)))))

;(fn request-go-format [client buffer-id callback]
;  (let [params (vim.lsp.util.make_formatting_params)]
;	(client.request "textDocument/formatting" params callback buffer-id)))
;
;(fn request-go-imports [client buffer-id callback]
;  (let [params (vim.lsp.util.make_range_params)]
;	(set params.context {:source {:organizeImports true}})
;	(client.request "textDocument/codeAction" params callback buffer-id)))

(fn new-ring-buffer [size]
	(var q-cap size)
	(var q-len 0)
	(var q-fst 1)
	(var q-lst 1)
	(var q-buf [])
	{:push (fn [val]
			 (tset q-buf q-lst val)
			 (set q-lst (-> q-lst (% q-cap) (+ 1))) 
			 (if (< q-len q-cap)
				 (set q-len (+ q-len 1))
				 (set q-fst (-> q-fst (% q-cap) (+ 1)))))
	 :data (fn [] q-buf)
	 :peek (fn [] (. q-buf q-fst))
	 :nil? (fn [] (= q-len 0))
	 :pop  (fn []
			 (if (= q-len 0)
				 nil
				 (let [val (. q-buf q-fst)]
				   (tset q-buf q-fst nil)
				   (set q-fst (-> q-fst (% q-cap) (+ 1)))
				   (set q-len (- q-len 1))
				   val)))
	})

(local TASKS (new-ring-buffer 4))

(fn request-handler [err result ctx]
  (case [err result ctx]
	[nil result ctx] (print "LSP REQUEST OK")
	[err _ _] (print "LSP REQUEST ERROR")))


(fn event-handler [args]
  (let [buffer-id args.buf] 
	(each [_ client (ipairs (vim.lsp.get_clients {:bufnr args.buf}))]
	 (if (client.supports_method "textDocument/formatting" {:bufnr buffer-id})
	  (let [params (vim.lsp.util.make_formatting_params)]
		(client.request "textDocument/formatting" params request-handler buffer-id))))))

(local group-id (vim.api.nvim_create_augroup "LSP" {:clear false}))

(fn on-attach [client buffer-id]
	(vim.api.nvim_clear_autocmds {:group group-id :buffer buffer-id})
  	(vim.api.nvim_create_autocmd 
	  "BufWritePost" 
	  {:group group-id
	   :buffer buffer-id 
	   :callback event-handler}))

{1 "neovim/nvim-lspconfig"
 :config (fn [] (let [lspconfig (require "lspconfig")] 
				  (lspconfig.gopls.setup {:on_attach on-attach})))}
