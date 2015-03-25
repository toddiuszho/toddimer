alias d='ls -FlaGh'
alias dg='ls -Fla'
alias dn='ls -Flan'

alias git=hub

case $TERM in
  xterm*)
    PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME%%.*}\007"';
    PS1='[\[\e[35m\]\t \[\e[36m\]\h \[\e[33m\]\W\[\e[0m\]]\$ ';;
    #PS1="\[\033]0;\u@\h: \w\007\]bash\\$ ";;
  *)
    PS1="bash\\$ ";;
esac

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

