# my vimrc setting

## Apply vimrc setting
```
cp ./vimrc ~/.vimrc
sudo apt-get update
sudo apt install neovim
sudo apt install nodejs
sudo apt install npm
sudo apt install nvm
nvm install --lts
sudo apt install yarn
ln -s ~/.vimrc ~/.config/nvim/init.vim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
copy and paste the code below to .vimrc
```
call plug#begin('~/.config/nvim/plugged')
" Use release branch
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Or latest tag
Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}
" Or build from source code by use yarn: https://yarnpkg.com
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
Plug 'morhetz/gruvbox'
Plug 'preservim/nerdtree'
Plug 'mattn/emmet-vim'
call plug#end()
```
open vim and type the code below
```
:w
:source %
:PlugInstall
```
copy and paste the code below to .vimrc
```
"테마 변경
st_dark="hard"
set background=dark
autocmd vimenter * colorscheme gruvbox

"nerdtree 단축키 설정
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
```
open vim and type the code below
```
:CocInstall coc-clangd coc-java coc-tsserver coc-css coc-json coc-html

:CocConfig

# copy and paste below code to coc configuration file
{
	"clangd.semanticHighlighting": true,
	"clangd.path":"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clangd",
	"coc.preferences.currentFunctionSymbolAutoUpdate": true,
	"diagnostic.errorSign": "✖",
	"diagnostic.warningSign": "⚠",
	"diagnostic.infoSign": "ℹ",
	"diagnostic.hintSign": "➤",
	"suggest.noselect": false,
	"suggest.echodocSupport": true,
	"codeLens.enable": true,
	"signature.enable": true,
	"suggest.preferCompleteThanJumpPlaceholder": true,
}
```
restart vim
