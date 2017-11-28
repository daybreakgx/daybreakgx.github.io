if filereadable(expand("~/.vimrc.bundles"))
    source ~/.vimrc.bundles
endif

set nocompatible
set nu
filetype plugin on
filetype indent on

syntax on

set ruler
set cursorline
set autoindent
set cindent
set smartindent

set tabstop=4
set softtabstop=4
set shiftwidth=4

