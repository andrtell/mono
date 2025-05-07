#!/usr/bin/env bash

OPT="pack/vendor/opt"
START="pack/vendor/start"
INSTALL="pack/vendor/install"

mkdir -p $START

cd $START

git -C "leap.nvim" pull || \
	git clone https://github.com/ggandor/leap.nvim.git

git -C "vim-sayonara" pull || \
	git clone https://github.com/mhinz/vim-sayonara.git

git -C "nvim-treesitter" pull || \
	git clone https://github.com/nvim-treesitter/nvim-treesitter.git

git -C "nvim-lspconfig" pull || \
	git clone https://github.com/neovim/nvim-lspconfig

git -C "vim-go" pull || \
	git clone https://github.com/fatih/vim-go.git

git -C "cmp-nvim-lsp" pull || \
	git clone https://github.com/hrsh7th/cmp-nvim-lsp

git -C "nvim-cmp" pull || \
	git clone https://github.com/hrsh7th/nvim-cmp

git -C "tiny-inline-diagnostic.nvim" pull || \
	git clone "https://github.com/rachartier/tiny-inline-diagnostic.nvim.git"

git -C "LuaSnip" pull || \
	git clone https://github.com/L3MON4D3/LuaSnip.git

git -C "friendly-snippets" pull || \
	git clone https://github.com/rafamadriz/friendly-snippets.git

git -C "auto-save.nvim" pull || \
	git clone https://github.com/pocco81/auto-save.nvim.git

git -C "nvim-autopairs" pull || \
	git clone https://github.com/windwp/nvim-autopairs.git
