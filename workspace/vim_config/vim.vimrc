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


" NERDTree
" 设置 NERDTree 快捷键
nmap <F2> : NERDTree<CR>
" 显示行号
let NERDTreeShowLineNumbers=1
" 显示隐藏文件
let NERDTreeShowHiden=1
" 设置宽度
let NERDTreeWinSize=50
" 显示书签列表
let NERDTreeShowBookmarks=1 

let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }
