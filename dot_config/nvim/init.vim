" VIM PLUG SETTINGS START HERE

" Automatic installation for vim-plug if not already installed
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')
Plug 'junegunn/vim-easy-align'
Plug 'kaicataldo/material.vim', { 'branch': 'main' }
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-fugitive'
Plug 'w0rp/ale'
Plug 'neovim/nvim-lspconfig'
Plug 'honza/vim-snippets'
Plug 'junegunn/fzf.vim'
Plug 'Yggdroot/indentLine'
Plug 'mattn/emmet-vim'
Plug 'pangloss/vim-javascript', { 'branch': 'master' }
call plug#end()

" VIM PLUG SETTINGS END HERE

" Required
filetype plugin indent on                                      " Enable support for autocmds and plugins to work
syntax enable                                                  " Enable syntax highlighting

" VIM BASIC SETTINGS START HERE
" Neovim specific options
if !has('nvim')
  set ttymouse=xterm2
endif

if has('nvim')
  set clipboard=unnamedplus
endif

" Theme settings
let g:material_terminal_italics = 1
let g:material_theme_style = 'palenight'
let g:airline_theme='material'
colorscheme material

" Enable language servers
lua << EOF
require'lspconfig'.bashls.setup{}
require'lspconfig'.dockerls.setup{}
require'lspconfig'.eslint.setup{}
require'lspconfig'.gdscript.setup{}
require'lspconfig'.jsonls.setup{}
require'lspconfig'.pyright.setup{}
require'lspconfig'.vimls.setup{}
EOF

" Language server commands
autocmd BufWritePre <buffer> <cmd>EslintFixAll<CR>

" Autocommands
autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path "%"
