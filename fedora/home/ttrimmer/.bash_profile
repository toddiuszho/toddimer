# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# User specific environment and startup programs
[ -d "${HOME}/bin" ] && PATH="${HOME}/bin:${PATH}"

export PATH

