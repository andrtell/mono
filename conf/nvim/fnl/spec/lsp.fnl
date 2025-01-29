(local S {})

(fn S.mk-que [size]
  (var q-cap size)
  (var q-len 0)
  (var q-fst 1)
  (var q-lst 1)
  (var q-buf [])
  {:push
  (fn [val]
	(tset q-buf q-lst val)
	(set q-lst (-> q-lst (% q-cap) (+ 1)))
	(if (< q-len q-cap)
		(set q-len (+ q-len 1))
		(set q-fst (-> q-fst (% q-cap) (+ 1)))))
  :data (fn [] q-buf)
  :peek (fn [] (. q-buf q-fst))
  :nil? (fn [] (= q-len 0))
  :len  (fn [] q-len)
  :pop 
  (fn []
	(if (= q-len 0)
		nil
		(let [val (. q-buf q-fst)]
		  (tset q-buf q-fst nil)
		  (set q-fst (-> q-fst (% q-cap) (+ 1)))
		  (set q-len (- q-len 1)) 
		  val)))
  })

(set S.jobs {})

(fn S.save-buffer [bufnr]
  (if (= bufnr (vim.api.nvim_get_current_buf)) (vim.cmd "noa update")))

(fn S.buffer-exists? [bufnr]
  (not= 0 (vim.fn.bufexists bufnr)))

(fn S.buffer-loaded? [bufnr]
  (vim.api.nvim_buf_is_loaded bufnr))

(fn S.buffer-unchanged? [bufnr]
  (= (vim.api.nvim_buf_get_var bufnr "jobtick") (vim.api.nvim_buf_get_var bufnr "changedtick")))

(fn S.buffer-insert-mode? [bufnr]
  (let [mode (vim.api.nvim_get_mode)]
	(vim.startswith mode.mode "i")))

(fn S.edit-ok? [bufnr]
  (and (S.buffer-exists? bufnr) (S.buffer-loaded? bufnr) (S.buffer-unchanged? bufnr) (not (S.buffer-insert-mode? bufnr))))

(fn S.update-jobtick [bufnr]
  (vim.api.nvim_buf_set_var bufnr "jobtick" (vim.api.nvim_buf_get_var bufnr "changedtick")))

(fn S.client-request [handler client-id method params bufnr]
  (let [client (vim.lsp.get_client_by_id client-id)]
	(client.request method params handler bufnr)))

(fn S.apply-code-action [result bufnr]
  (each [_ action (ipairs result)]
	(case action.kind
	  "source.organizeImports"
	  (when (S.edit-ok? bufnr)
		(vim.lsp.util.apply_workspace_edit action.edit "utf-16")))))

(fn S.handle-code-action [err result ctx]
  (case [err result ctx]
	[err _ _] (print (string.format "(LSP Error: %d): %s" err.code err.message))
	[_ result ctx] (S.apply-code-action result ctx.bufnr)))

(fn S.request-code-action [handler [client-id bufnr]]
  (let [params (vim.lsp.util.make_range_params)]
	(set params.context {:source {:organizeImports true}})
	(S.client-request handler client-id "textDocument/codeAction" params bufnr)))

(fn S.apply-format [res bufnr]
  (when (S.edit-ok? bufnr)
	(vim.lsp.util.apply_text_edits res bufnr "utf-16")
	(S.update-jobtick bufnr)))

(fn S.handle-format [err result ctx]
  (case [err result ctx]
	[err _ _] (vim.lsp.log (string.format "(LSP Error: %d): %s" err.code err.message))
	[_ result ctx] (S.apply-format result ctx.bufnr)))

(fn S.request-format [handler [client-id bufnr]]
  (let [params (vim.lsp.util.make_formatting_params)]
	(S.client-request handler client-id "textDocument/formatting" params bufnr)))

(fn S.run-jobs [bufnr]
  (let [rec (fn [handler] (fn [err res ctx] (handler err res ctx) (vim.schedule (fn [] (S.run-jobs bufnr)))))
		jobs (. S.jobs bufnr)]
	(if (jobs.nil?) (S.save-buffer bufnr) (case (jobs.pop) [requester handler args] (requester (rec handler) args)))))

(fn S.on-write-event [client-id]
  (fn [args]
	(let [bufnr args.buf 
				jobs (. S.jobs bufnr) 
				idle? (jobs.nil?)]
	  (jobs.push [S.request-format S.handle-format [client-id bufnr]]) 
	  (jobs.push [S.request-code-action S.handle-code-action [client-id bufnr]]) 
	  (S.update-jobtick bufnr)
	  (if idle? (S.run-jobs bufnr)))
	nil))

(set S.group (vim.api.nvim_create_augroup "LSP" {:clear false}))

(fn S.on-attach [client bufnr]
  (tset S.jobs bufnr (S.mk-que 21))
  (vim.api.nvim_clear_autocmds {:group S.group :buffer bufnr})
  (vim.api.nvim_create_autocmd 
	"BufWritePost"
	{:group S.group 
	:buffer bufnr
	:callback (S.on-write-event client.id)}))

(fn S.config []
  (let [lspconfig (require "lspconfig")]
	(lspconfig.gopls.setup {:on_attach S.on-attach})))

{1 "neovim/nvim-lspconfig"
:config S.config} 
