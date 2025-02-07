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

git -C "parinfer-rust" pull || \
	git clone https://github.com/eraserhd/parinfer-rust.git

git -C "vim-sayonara" pull || \
	git clone https://github.com/mhinz/vim-sayonara.git

git -C "tangerine.nvim" pull || \
	git clone https://github.com/udayvir-singh/tangerine.nvim.git

git -C "nvim-treesitter" pull || \
	git clone https://github.com/nvim-treesitter/nvim-treesitter.git

git -C "conjure" pull || \
	git clone https://github.com/Olical/conjure.git

git -C "nvim-paredit" pull || \
	git clone https://github.com/julienvincent/nvim-paredit.git
