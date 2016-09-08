alias d='gls -FlaGh --color=yes'
alias dg='gls -Fla --color=yes'
alias dn='gls -Flan --color=yes'

alias git=hub

# Prompt and Title
case $TERM in
  xterm*)
    #PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME%%.*}\007"';
    PROMPT_COMMAND='echo -ne "\033]0;$(basename $(pwd))\007"';
    PS1='[\[\e[35m\]\t \[\e[36m\]\h \[\e[33m\]\W\[\e[0m\]]\$ ';;
    #PS1="\[\033]0;\u@\h: \w\007\]bash\\$ ";;
  *)
    PS1="bash\\$ ";;
esac

# VI
export EDITOR=/usr/bin/vi

# Perforce
[ -e "$HOME/.p4rc" ] && . "$HOME/.p4rc"

# RVM
#_rvm="$HOME/.rvm/bin"
#export PATH="${PATH}:${_rvm}" # Add RVM to PATH for scripting

# Java
export JAVA_HOME=/usr/java/default

# Ant
#export ANT_HOME=$HOME/depot/ext/ant/ant-1.9
#PATH="${PATH}:$ANT_HOME/bin"
#alias ant='ant -logger org.apache.tools.ant.listener.AnsiColorLogger'

# JBoss
export JAVA_HOME=$(/usr/libexec/java_home -v1.8)

# Terraform
#PATH="$PATH:/opt/terraform/default"

# Dupes
alias grep='/usr/local/bin/ggrep'
alias find='/usr/local/bin/gfind'

alias rcat="ggrep -Pv '^($|#)'"

kitchen() {
  if [ "provision" = "$1" ]; then
    shift 1
    command kitchen converge "$@"
  else
    command kitchen "$@"
  fi
}

alias berkbump='git pull --tag; [ -e Berksfile.lock ] && rm Berksfile.lock; thor version:current && bundle exec berks install && git add Berksfile.lock && git commit -m "lock" && git push'
alias berkit='git pull --tag; [ -e Berksfile.lock ] && rm Berksfile.lock; thor version:current && bundle exec berks install && git add Berksfile.lock'

alias supernova='command supernova -q'

alias ipa='ssh svc1 ipa'

alias md5sum='md5'

alias sha256sum='shasum -a 256'

alias sha512sum='shasum -a 512'

alias myprivateipv4="ifconfig | grep -Po '(?<=inet\s)[\d\.]+' | grep -v '127.0.0.1'"

export RVT='rack.viverae.technology'

