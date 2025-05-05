#!/usr/bin/env bash

OPT="pack/vendor/opt"
START="pack/vendor/start"
INSTALL="pack/vendor/install"

mkdir -p $OPT
mkdir -p $START
mkdir -p $INSTALL

cd $INSTALL

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
