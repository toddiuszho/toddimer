if [ -n "$BASH_VERSION" -o -n "$KSH_VERSION" -o -n "$ZSH_VERSION" ]; then
  if [ "Cygwin" = `uname -o` ]; then
    alias vi >/dev/null 2>&1 || alias vi='/usr/bin/vim'
  else
    alias vi >/dev/null 2>&1 || alias vi=vim
  fi
fi
