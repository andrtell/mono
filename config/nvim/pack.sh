#!/usr/bin/env bash

ROOT="pack/vendor/start"

mkdir -p $ROOT

cd $ROOT

DIR="leap.nvim"		git -C "$DIR" pull || git clone https://github.com/ggandor/leap.nvim.git "$DIR"
DIR="parinfer-rust"	git -C "$DIR" pull || git clone https://github.com/eraserhd/parinfer-rust.git "$DIR"
DIR="vim-sayonara"	git -C "$DIR" pull || git clone https://github.com/mhinz/vim-sayonara.git "$DIR"
DIR="tangerine.nvim"	git -C "$DIR" pull || git clone https://github.com/udayvir-singh/tangerine.nvim.git "$DIR"
