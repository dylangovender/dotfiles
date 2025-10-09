" -------- Basic UI --------
set nocompatible
syntax on
filetype plugin indent on

" Show relative line numbers (with absolute for current line)
set number
set relativenumber

" Highlight search matches
set hlsearch
set incsearch

" Better indentation and tabs
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent

" Highlight matching brackets
set showmatch
" Always show status line
set laststatus=2

" Enable mouse support
set mouse=a

" -------- Clipboard --------
set clipboard=unnamedplus

" -------- Navigation --------
set scrolloff=5         " keep 5 lines visible when scrolling
" set cursorline          " highlight current line

" -------- Persistent undo --------
set undofile
set undodir=~/.vim/undo

" -------- Jump to last edit position --------
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif

" -------- Colors --------
set termguicolors

" -------- Optional extras --------
set wildmenu            " better tab completion
set showcmd             " show partial commands in bottom right

" --- Move lines or blocks up and down (macOS Option + J / K) ---
nnoremap <silent> <A-j> :m .+1<CR>==
nnoremap <silent> <A-k> :m .-2<CR>==

vnoremap <silent> <A-j> :m '>+1<CR>gv=gv
vnoremap <silent> <A-k> :m '<-2<CR>gv=gv

inoremap <silent> <A-j> <Esc>:m .+1<CR>==gi
inoremap <silent> <A-k> <Esc>:m .-2<CR>==gi
