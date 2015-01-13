function AfterInstall() {
  local script=$DOTCONF/after/$1
  if [[ -f $script ]]; then
    pushd $DOTCONF > /dev/null
    source $script
    popd > /dev/null
  fi
}

function YesOrNo() {
  read -p "Install $1 (y/N)?" choice
  case "$choice" in 
    y|Y ) return 1;;
    n|N|* ) return 0;;
  esac
}

function DropboxDotfileSymlink() {
  if [[ ! -L $HOME/.$1 ]]; then
    echo "symlinking .$1 to dropbox"
    ln -s $HOME/Dropbox/dotfiles_private/$1 $HOME/.$1
  fi
}

function CheckInstall() {
  hash $1 >/dev/null 2>&1 || YesOrNo $1
}

function EnableZmodule() {
  sed "/prezto:load..pmodule/a\\ \ \'$1\' \\\\" ~/.zpreztorc > /tmp/zpreztorc
  if [[ "$?" -eq 0 ]]; then
    cat /tmp/zpreztorc > ~/.zpreztorc
    rm /tmp/zpreztorc
  else
    echo "Failed to enable zmodule $1"
  fi
}


if [[ -f /bin/zsh ]]; then
  test -f /bin/zsh && test "$SHELL" = "/bin/zsh" || {
    echo "Change shell to zsh?"
    YesOrNo || {
       chsh -s /bin/zsh
    }
  }
  if [[ ! -f $HOME/.zpreztorc ]]; then
    echo "Install zprezto?"
    YesOrNo || {
      # Installing zprezto
      $DOTCONF/install_zprezto.zsh
      echo 'PATH="$PATH:'$MY_BINS':'$MY_NODE_BINS'"' >> ~/.zshrc
      EnableZmodule "git"
    }
    mkdir $HOME/.gopath
    echo 'export GOPATH="$HOME/.gopath"' >> ~/.zshenv
    echo 'export PATH="$PATH:$GOPATH/bin"' >> ~/.zshenv
  fi
  # Customize the prompt
  cat $MY_DOTFILES/prompt_sorin_setup > ~/.zprezto/modules/prompt/functions/prompt_sorin_setup
else
  echo "zshell not found, skipping zprezto install" >&2
fi


# Cleaning dotfiles
rm -rf \
    ~/.vim \
    ~/.vimrc \
    ~/.tmux.conf \
    ~/.tmux-osx.conf \
    ~/.tmux-nested.conf \
    ~/.ackrc

# Linking dotfiles
ln -s $MY_DOTFILES/vim/vimfiles     ~/.vim
ln -s $MY_DOTFILES/vim/vimrc        ~/.vimrc
ln -s $MY_DOTFILES/tmux.conf        ~/.tmux.conf
ln -s $MY_DOTFILES/tmux-osx.conf    ~/.tmux-osx.conf
ln -s $MY_DOTFILES/tmux-nested.conf ~/.tmux-nested.conf
ln -s $MY_DOTFILES/ackrc.conf       ~/.ackrc
echo "vim files symlinked"
echo "tmux files symlinked"

# Private Dotfiles
DropboxDotfileSymlink "ssh"
DropboxDotfileSymlink "weechat"
DropboxDotfileSymlink "lolcommits"
DropboxDotfileSymlink "misc"

source $DOTCONF/gitconfig.sh

vim +BundleInstall +qall
