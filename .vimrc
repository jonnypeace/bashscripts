set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'jiangmiao/auto-pairs'
Plugin 'ycm-core/YouCompleteMe'

Plugin 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
Plugin 'git://git.wincent.com/command-t.git'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}
" Searching with fuzzy finder
Plugin 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

Plugin 'plasticboy/vim-markdown' " markdown
Plugin 'preservim/nerdtree' " nerdtree
Plugin 'ryanoasis/vim-devicons' " for nerd-tree
Plugin 'jdhao/better-escape.vim' " remaps escape key to fast type jj

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line`

" syntax highlighting
syntax on
" line numbers
set number
" cursorline
set cursorline
" cursorline colour
highlight CursorLine ctermbg=236 cterm=None
" search result highlighting
set hlsearch

" tabs are 4 wide
set tabstop=4
" so are indents
set shiftwidth=4
" make my tabs into spaces
" "set expandtab
" make indenting automatic
set autoindent

" required for powerline
set laststatus=2
set t_Co=256

" columns to remind us about the max column width from the style guide
" set colorcolumn=80,100
" highlight ColorColumn ctermbg=235

map <C-Tab> :tabnext

" FZF key bindings ctrl+f for fuzzy finding
nnoremap <C-f> :FZF<CR>
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-i': 'split',
  \ 'ctrl-v': 'vsplit' }

" tab stuff
nnoremap <Space>t :tabnew<CR>
nnoremap <Space>c :tabclose<CR>
nnoremap <Space>p :tabprevious<CR>
nnoremap <Space>n :tabnext<CR>
nnoremap <Space>1 1gt<CR>
nnoremap <Space>2 2gt<CR>
nnoremap <Space>3 3gt<CR>
nnoremap <Space>4 4gt<CR>
nnoremap <Space>5 5gt<CR>

nnoremap <Space>nt :NERDTreeToggle<CR>

nnoremap S :%s//gc<Left><Left><Left>
