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

;(fn S.request-handler [] nil)
;
;(fn S.run-next-job []
;  (print "RUN NEXT JOB")
;  (case (jobs.peek)
;	[_ buffer-id client "textDocument/formatting"]
;	(do
;	  	(print "FORMATTING")
;		(let [params (vim.lsp.util.make_formatting_params)]
;		  (client.request "textDocument/formatting" params S.request-handler buffer-id)))
;	[_ buffer-id client "textDocument/codeAction"]
;	(do
;	  	(print "CODE ACTION")
;		(let [params (vim.lsp.util.make_range_params)]
;		  (set params.context {:source {:organizeImports true}}) 
;		  (client.request "textDocument/codeAction" params S.request-handler buffer-id)))
;	_
;	(do 
;	  (print "NO MATCH")
;	  (jobs.pop))))
;
;(fn S.request-handler [err result ctx]
;  (case [err result ctx]
;	[nil result ctx] (print (.. "OK: " (math.random 0 100)))
;	[err _ _] (print "LSP REQUEST ERROR"))
;  (jobs.pop)
;  (S.run-next-job))

;(fn S.event-handler [args]
;  (let [clients (vim.lsp.get_clients {:bufnr args.bufnr})]
;	(each [_ client (ipairs clients)]
;	  (S.job-que.push [:format client args.buf])
;	  (S.job-que.push [:import client args.buf])))
;  (vim.schedule S.run-job)
;  nil)

(local S {})

(fn S.mk-que [size]
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
	 :len  (fn [] q-len)
	 :pop  (fn []
			 (if (= q-len 0)
				 nil
				 (let [val (. q-buf q-fst)]
				   (tset q-buf q-fst nil)
				   (set q-fst (-> q-fst (% q-cap) (+ 1)))
				   (set q-len (- q-len 1))
				   val)))
	})

(set S.job-que (S.mk-que 10))

(fn S.format [client bufnr callback]
  (let [params (vim.lsp.util.make_formatting_params)]
	(client.request "textDocument/formatting" params callback bufnr)))

(fn S.import [client bufnr callback]
  (let [params (vim.lsp.util.make_formatting_params)]
	(client.request "textDocument/formatting" params callback bufnr)))

(fn S.response-handler [err res ctx] nil)

(fn S.run-job []
  (let [rec (fn [err res ctx]
			  (S.response-handler err result ctx)
			  (vim.schedule S.run-job))]
	  (if (S.job-que.nil?)
		  nil
		  (case (S.job-que.pop)
			[:format client bufnr] (S.format client bufnr rec)
			[:import client bufnr] (S.import client bufnr rec)))))

(fn S.event-handler [client]
  (fn [args]
	  (S.job-que.push [:format client args.buf])
	  (S.job-que.push [:import client args.buf])
	  (S.run-job)
	  nil))

(set S.group (vim.api.nvim_create_augroup "format-lsp" {:clear false}))

(fn S.on-attach [client bufnr]
	(vim.api.nvim_clear_autocmds {:group S.group :buffer bufnr})
  	(vim.api.nvim_create_autocmd "BufWritePost" {:group S.group
								 				 :buffer bufnr
												 :callback (S.event-handler client)}))

{1 "neovim/nvim-lspconfig"
 :config (fn [] (let [lspconfig (require "lspconfig")] 
				  (lspconfig.gopls.setup {:on_attach S.on-attach})))}
