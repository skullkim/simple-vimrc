# my vimrc setting

## Apply vimrc setting
```bash
cp ./vimrc ~/.vimrc
sudo apt-get update
sudo apt install neovim
sudo apt install nodejs
sudo apt install npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash
nvm install --lts
sudo apt install yarn
ln -s ~/.vimrc ~/.config/nvim/init.vim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
.vimrc로 nvim 세팅을 변경하기 위해 다음 코드를 ~/.config/nvim/init.vim에 작성한다
```bash
set runtimepath+=~/.vim,~/.vim/after
set packpath+=~/.vim
source ~/.vimrc
```

vimrc파일을 ~/경로에 놓고 .vimrc로 변경
그 후 .vimrc를 킨 채로 아래 커맨드 입력
```
:w
:source %
:PlugInstall
:CocInstall coc-clangd coc-java coc-tsserver coc-css coc-json coc-html coc-kotlin
:CocConfig
```
CocConfig를 통해 열린 창에 아래 코드 입력
```
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
vim 재시작
