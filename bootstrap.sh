DOTCONF=$(dirname $(readlink -f $0))
MY_DOTFILES=$DOTCONF/dotfiles
MY_BINS=$DOTCONF/bin

function manifest() {
  source $DOTCONF/$1.sh
}

case `uname` in
  Linux)
    manifest "deb"
    ;;
  darwin)
    manifest "osx"
    ;;
esac
