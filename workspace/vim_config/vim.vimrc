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
nmap <F2> :NERDTreeTabsToggle<CR>
" 显示行号
let NERDTreeShowLineNumbers=1
" 显示隐藏文件
let NERDTreeShowHidden=1
" 设置宽度
let NERDTreeWinSize=30
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

" taglist
" 设置tags的搜索路径
set tags=,/tags;,tags
" 设置ctags路径
let Tlist_Ctags_Cmd='/usr/bin/ctags'
" 启动vim后自动打开taglist
let Tlist_Auto_Open=1
" 不同时显示多个文件的taglist
let Tlist_Show_One_File=1
" taglist为最后一个窗口是自动退出vim
let Tlist_Exit_OnlyWindow=1
" 设置taglist在右边显示
let Tlist_Use_Right_Window=1
" 设置打开关闭taglist的快捷键
nmap <F8> :TlistToggle<CR>
" 更新ctags标签文件快捷键
nmap <F6> :!ctags -R<CR>

if has("cscope")
    set csprg=/usr/bin/cscope
	set csto=1
	set cst
	set nocsverb
	" add any database in current directory
	if filereadable("cscope.out")
		cs add cscope.out
	endif
	set csverb
endif
nmap <C-@>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>d :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-@>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>


nmap <C-\>s :scs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :scs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>d :scs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :scs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :scs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :scs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>

" Powerline
" 总是显示状态栏 
set laststatus=2
" Powerline显示背景颜色
set t_Co=256
let g:Powerline_symbols='unicode'



