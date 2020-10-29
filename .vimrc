"source /tools/au_IT/default_vimrc
"source /home/eswartze/default_vimrc

"
" misc
"
"hi Define  term=bold ctermfg=LightGreen guifg=Blue
"


"filetype plugin on
set nocp              " be vim, not vi ;-)
"set makeprg=gmake    " use gnumake for :make
set ttyfast           " redraw at reasonable times

"
"Craigk 11/14/03 - Trying to get vi not to clear
"
set t_ti= t_te=
"set autoindent
set expandtab
set shiftwidth=3
set tabstop=3
"set mouse=a
"set ttymouse=xterm2

"
" wrapping
"
set nowrap            " don't wrap lines!
" wrap toggle
map tw :set invwrap
map nu :set undolevels=-1

"
" searching
"
set ignorecase        " ignore case while searching REGEX, but:
set smartcase         " if capitals are used in REGEX, use them
set hlsearch          " highlight all occurences of REGEX
set incsearch         " highlight and jump to first occurence of REGEX
" toggle hlsearch
map th :set invhlsearch

"
" code style
"
"set tabstop=2         " use 2 space tabs
"set expandtab         " expand tabs into spaces (bad for Makefiles)
set formatoptions=    " disable unwanted vim formating
set showmatch         " disable matching [({ for ]}] when inserted

"
" status line
"
set ruler             " show row/col information
set shortmess=a       " show terse messages in status line
set showcmd           " show what command is being typed
set cmdheight=2       " try to eliminate some "press RETURN" messages
set laststatus=2      " always display a status line

"
" mouse (annoying, disable for now)
"
"set mouse=a           " use the mouse to move the cursor in all modes
"set mousehide         " hide the mouse cursor when appropriate

"
" filename completion
"
"set wildignore+=*~    " ignore ~    files for filename completion
"set wildignore+=*.bak " ignore .bak files for filename completion
"set wildignore+=*.o   " ignore .o   files for filename completion

"
" when <TAB> is used for filename completion, display the longest
" common matching strint, and display a list of all possible matches
" each time <TAB> is hit again, choose the next full match
"
"set wildmode=longest:list,full

"
" emacs sytle window management
"
" split current into 2 windows
map 2 :split
" go to next window
map o 
" make current the only window
map 1 o

"
" vile style buffer management
"
map bl  :buffers
map b1  :1buffer!
map b2  :2buffer!
map b3  :3buffer!
map b4  :4buffer!
map b5  :5buffer!
map b6  :6buffer!
map b7  :7buffer!
map b8  :8buffer!
map b9  :9buffer!
map bn  :bnext!
map bp  :bprev!
map bd  :bdelete

"
" tags
"
map tm :!etags *.[cCh]
map tf 
map tb 
map tl :tags
map [11~ 0A 0Dppj

"
" syntax highlighting
"
set background=dark
syntax enable
colorscheme drunkenmonkeyfight
"colorscheme torte
let g:hybrid_custom_term_colors = 1
"colorscheme hybrid 
"colorscheme solarized 
"
" automatically handle compressed files
"
augroup gzip
  autocmd!
  autocmd BufReadPre,FileReadPre     *.gz set bin
  autocmd BufReadPost,FileReadPost   *.gz '[,']!gunzip
  autocmd BufReadPost,FileReadPost   *.gz set nobin
  autocmd BufReadPost,FileReadPost   *.gz execute ":doautocmd BufReadPost " . expand("%:r")
  autocmd BufWritePost,FileWritePost *.gz !mv <afile> <afile>:r
  autocmd BufWritePost,FileWritePost *.gz !gzip <afile>:r

  autocmd FileAppendPre              *.gz !gunzip <afile>
  autocmd FileAppendPre              *.gz !mv <afile>:r <afile>
  autocmd FileAppendPost             *.gz !mv <afile> <afile>:r
  autocmd FileAppendPost             *.gz !gzip <afile>:r
augroup END
augroup compress
  autocmd!
  autocmd BufReadPre,FileReadPre     *.Z set bin
  autocmd BufReadPost,FileReadPost   *.Z '[,']!uncompress
  autocmd BufReadPost,FileReadPost   *.Z set nobin
  autocmd BufReadPost,FileReadPost   *.Z execute ":doautocmd BufReadPost " . expand("%:r")
  autocmd BufWritePost,FileWritePost *.Z !mv <afile> <afile>:r
  autocmd BufWritePost,FileWritePost *.Z !compress <afile>:r

  autocmd FileAppendPre              *.Z !uncompress <afile>
  autocmd FileAppendPre              *.Z !mv <afile>:r <afile>
  autocmd FileAppendPost             *.Z !mv <afile> <afile>:r
  autocmd FileAppendPost             *.Z !compress <afile>:r
augroup END

"au BufNewFile,BufRead athdlsv.log   setf athdlsv

