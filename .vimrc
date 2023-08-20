set number ruler
set autoindent smartindent expandtab 
syntax enable
filetype plugin indent on
autocmd FileType python setlocal ts=4 sts=4 sw=4 
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 

call plug#begin()

Plug 'sainnhe/sonokai'
Plug 'jiangmiao/auto-pairs'
Plug 'preservim/nerdtree'

call plug#end()

set foldenable
set foldlevelstart=20
set foldmethod=indent
colorscheme sonokai

set runtimepath+=~/.vim/plugged/auto-pairs
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'jiangmiao/auto-pairs'

call vundle#end()           
filetype plugin indent on 
