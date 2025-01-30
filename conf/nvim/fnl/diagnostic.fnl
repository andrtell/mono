(vim.cmd "sign define DiagnosticSignError text= texthl= linehl= numhl=")

(local ns (vim.api.nvim_create_namespace "ul"))
(local show vim.diagnostic.handlers.underline.show)
(local hide vim.diagnostic.handlers.underline.hide)

(set vim.diagnostic.handlers.underline
  {:show (fn [_ bufnr d o] 
          (each [i _ (ipairs d)] 
            (if (= (. d i :end_col) (. d i :col))
                (tset d i :end_col (+ (. d i :end_col) 1))))
          (show ns bufnr d o))
   :hide (fn [_ bufnr] (hide ns bufnr))})
