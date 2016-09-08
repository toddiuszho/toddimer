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
export JAVA_HOME=$(/usr/libexec/java_home -v1.8)

# Ant
#export ANT_HOME=$HOME/depot/ext/ant/ant-1.9
#PATH="${PATH}:$ANT_HOME/bin"
#alias ant='ant -logger org.apache.tools.ant.listener.AnsiColorLogger'

# JBoss
export JBOSS_HOME=/opt/jboss/jboss7

# Terraform
#PATH="$PATH:/opt/terraform/default"

# Dupes
alias grep='/usr/local/bin/ggrep'
alias find='/usr/local/bin/gfind'

# Files
alias rcat="ggrep -Pv '^($|#)'"

# Chef
kitchen() {
  if [ "provision" = "$1" ]; then
    shift 1
    command kitchen converge "$@"
  else
    command kitchen "$@"
  fi
}
alias berkbump='git pull --tags; berks update && git commit -m "lock" --no-verify Berksfile.lock && git push --no-verify'

# Rackspace
alias supernova='command supernova -q'

# Identity
alias ipa='ssh svc1 ipa'

# Checksum
alias md5sum='md5'
alias sha256sum='shasum -a 256'
alias sha512sum='shasum -a 512'

# Networking
alias myprivateipv4="ifconfig | grep -Po '(?<=inet\s)[\d\.]+' | grep -v '127.0.0.1'"
export RVT='rack.viverae.technology'

# VHMS
alias build-services='../gradlew clean assembleDist && cd build/distributions; jar -xf services.zip services/bin/services services/bin/servicesWrapper.sh'
alias build-sdp='../gradlew clean assembleDist && cd build/distributions; jar -xf sdp.zip sdp/bin/sdp sdp/bin/sdpWrapper.sh sdp/bin/sdpEmployerChange sdp/bin/sdpEmployerChange.sh sdp/bin/sdpConsumer sdp/bin/sdpConsumerWrapper.sh'

[ -f $HOME/.vacuity ] && . $HOME/.vacuity

