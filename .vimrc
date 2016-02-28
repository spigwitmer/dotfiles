syntax on
set expandtab sw=4 ts=4 nocompatible nu
set laststatus=2
set statusline=%t\ \ [%{strlen(&fenc)?&fenc:'none'},%{&ff}]\ \ %h%m%r%y%=%c,%l/%L\ %P
set encoding=utf-8
cnoreabbrev tn tabnew
noremap <F6> :tabprevious<CR>
noremap <F7> :tabnext<CR>
map Q <Nop>
map q <Nop>
execute pathogen#infect()
set statusline+=\ \ %{fugitive#statusline()}
syntax on
filetype plugin indent on
set textwidth=72
let g:airline#extensions#tabline#enabled = 1
