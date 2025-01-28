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

;(fn S.buffer-imports [client-id bufnr callback]
;  (let [params (vim.lsp.util.make_range_params)]
;	(set params.context {:source {:organizeImports true}})
;	(S.client-request client-id bufnr "textDocument/codeAction" params callback)))
;
;
;(fn S.handle-buffer-imports [err res ctx]
;  (print "called: S.handle-buffer-imports")
;  (case [err res ctx]
;	[err _ _] (vim.lsp.log (string.format "(LSP Error: %d): %s" err.code err.message))
;	[_ res ctx] (if (not= 0 (vim.fn.bufexists ctx.bufnr))
;					(do 
;					  (if (not (vim.api.nvim_buf_is_loaded ctx.bufnr))
;						  (vim.fn.bufload ctx.bufnr))
;					  (each [_ result (pairs res)]
;						(each [_ action (pairs result)]
;						  (print action)))
;
;					  ))))
;					  ;; (vim.lsp.util.apply_text_edits res ctx.bufnr "utf-16")
;					  ;(if (= ctx.bufnr (vim.api.nvim_get_current_buf))
;					  ; (vim.cmd "update"))))))

(fn S.request [handler method params client-id bufnr]
  (let [client (vim.lsp.get_client_by_id client-id)]
	(client.request method params handler bufnr)))

(fn S.save-format [res ctx]
	(if (not= 0 (vim.fn.bufexists ctx.bufnr)) 
		(do 
		  (if (not (vim.api.nvim_buf_is_loaded ctx.bufnr))
			  (vim.fn.bufload ctx.bufnr))
		  (vim.lsp.util.apply_text_edits res ctx.bufnr "utf-16")
		  (if (= ctx.bufnr (vim.api.nvim_get_current_buf))
			  (vim.cmd "update")))))

(fn S.handle-format [err res ctx]
  (case [err res ctx]
	[err _ _] (vim.lsp.log (string.format "(LSP Error: %d): %s" err.code err.message))
	[_ res ctx] (S.save-format)))

(fn S.request-format [handler client-id bufnr]
  (let [params (vim.lsp.util.make_formatting_params)]
	(S.request handler "textDocument/formatting" params client-id bufnr)))

(fn S.run-job []
  (let [rec (fn [handler] (fn [err res ctx] (handler err res ctx) (S.run-job)))]
	(if (S.job-que.nil?)
		nil
		(case (S.job-que.pop)
		  [requester handler client-id bufnr] (requester (rec handler) client-id bufnr)))))

(fn S.on-event [client-id]
  (fn [args]
	(S.job-que.push [S.request-format S.handle-format client-id args.buf])
	;(S.job-que.push [:code-actions client-id args.buf])
	(S.run-job) 
	nil))

(set S.group (vim.api.nvim_create_augroup "format-lsp" {:clear false}))

(fn S.on-attach [client bufnr]
  (vim.api.nvim_clear_autocmds {:group S.group :buffer bufnr})
  (vim.api.nvim_create_autocmd 
	"BufWritePost"
	{:group S.group 
	 :buffer bufnr
	 :callback (S.on-event client.id)}))

(fn S.config []
  (let [lspconfig (require "lspconfig")]
	(lspconfig.gopls.setup {:on_attach S.on-attach})))

{1 "neovim/nvim-lspconfig"
 :config S.config} 
