(let [ocp-indent-path (vim.fn.expand "$HOME/.opam/default/share/ocp-indent/vim")]
	(vim.opt.rtp:prepend ocp-indent-path))
