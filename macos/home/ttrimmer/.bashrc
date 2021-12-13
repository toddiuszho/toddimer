# Directory listing
alias d='gls -FlaGh --color=yes'
alias dg='gls -Fla --color=yes'
alias dn='gls -Flan --color=yes'

# Git
PATH="${PATH}:${HOME}/bin:${HOME}/github/so-fancy/diff-so-fancy"

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

# Visual Studio Code
PATH="${PATH}:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Perforce
[ -e "$HOME/.p4rc" ] && . "$HOME/.p4rc"

# RVM
#_rvm="$HOME/.rvm/bin"
#export PATH="${PATH}:${_rvm}" # Add RVM to PATH for scripting

# Java
#export JAVA_HOME=$(/usr/libexec/java_home -v1.8)
#export JAVA_HOME=$(/usr/libexec/java_home)

# sdkman
export SDKMAN_DIR="$HOME/.sdkman"
scr="${SDKMAN_DIR}/bin/sdkman-init.sh"
[ -f "${scr}" ] && . "${scr}"
unset scr

# Ant
#export ANT_HOME=$HOME/depot/ext/ant/ant-1.9
#PATH="${PATH}:$ANT_HOME/bin"
#alias ant='ant -logger org.apache.tools.ant.listener.AnsiColorLogger'

# JBoss
export JBOSS_HOME=/opt/jboss/jboss7

# python
PATH="${PATH}:/Library/Frameworks/Python.framework/Versions/3.10/bin"

# gcloud
for scr in path completion; do
  fullscr="${HOME}/google-cloud-sdk/${scr}.bash.inc"
  [ -f "${fullscr}" ] && . "${fullscr}"
done
unset scr
unset fullscr
export CLOUDSDK_PYTHON=/usr/bin/python

# Terraform
#PATH="$PATH:/opt/terraform/default"

# GNU + Dupes = GNUpes
declare -a gnupes=(find grep)
for dupe in "${gnupes[@]}"; do
  [ -f "${BREWBIN}/g${dupe}" ] && eval "alias ${dupe}='${BREWBIN}/g${dupe}'"
done

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
alias nssh="ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -o 'GlobalKnownHostsFile=/dev/null'"

# Google
scr="${HOME}/github/toddiuszho/gman/gman.sh"
[ -f "${scr}" ] && . "${scr}"
unset scr

fuego-cnect() {
  export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/.config/gcloud/legacy_credentials/cnect.owner@gmail.com/adc.json"
}

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Dynamic bash completions
if [ -d "${HOME}/.local/share/bash-completion/completions/" ]; then
  for fz in $(LC_COLLATE=C ls -1 ${HOME}/.local/share/bash-completion/completions); do
    . "${fz}"
  done
fi

# npm
if which npmrc-export 2>&1 >/dev/null; then
  . <(npmrc-export)
fi

# ecli
# export GOOGLE_APPLICATION_CREDENTIALS=$(gfind ${HOME}/.ecli -type f -name '*.json')
