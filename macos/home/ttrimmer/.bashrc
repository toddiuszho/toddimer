# Directory listing
alias d='gls -FlaGh --color=yes'
alias dg='gls -Fla --color=yes'
alias dn='gls -Flan --color=yes'

# Misc
alias hl='head -n34'

# Git
PATH="${PATH}:${HOME}/bin:${HOME}/github/so-fancy/diff-so-fancy"
alias gsave='export OLD_BRANCH=$(git rev-parse --abbrev-ref HEAD)'
alias grestore='git checkout $OLD_BRANCH'

preexec() {
  _last_command=$1
  if [ "UNSET" == "${_timer}" ]; then
    _timer=$SECONDS
  else 
    _timer=${_timer:-$SECONDS}
  fi 
}

_maybe_speak() {
    local elapsed_seconds=$1
    # if (( elapsed_seconds > 30 )); then
    #     local c
    #     c=$(echo "${_last_command}" | cut -d' ' -f1)
    #     ( say "finished ${c}" & )
    # fi
}

precmd() {
  if [ "UNSET" == "${_timer}" ]; then
     timer_show="0s"
  else 
    elapsed_seconds=$((SECONDS - _timer))
    _maybe_speak ${elapsed_seconds}
    timer_show="$(format-duration seconds $elapsed_seconds)"
  fi
  _timer="UNSET"

  # History stuff from http://unix.stackexchange.com/questions/200225/search-history-from-multiple-bash-session-only-when-ctrl-r-is-used-not-when-a
  # Whenever a command is executed, write it to a global history
  history -a ~/.bash_history.global
}

[ -f "${HOME}/.bash-preexec.sh" ] && . "${HOME}/.bash-preexec.sh"

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
#export CLOUDSDK_PYTHON=/usr/bin/python
export CLOUDSDK_PYTHON=/usr/bin/python3

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
declare -a completion_dirs=(
  ${HOME}/.local/share/bash-completion/completions
  #/opt/homebrew/etc/bash_completion.d
)
for completion_dir in "${completion_dirs[@]}"; do
  if [ -d "${completion_dir}" ]; then
    for fz in $(LC_COLLATE=C ls -1 ${completion_dir}); do
      [ 'brew' != "${fz}" ] && . "${fz}"
    done
  fi
done

# npm
if which npmrc-export 2>&1 >/dev/null; then
  . <(npmrc-export)
fi
alias nixnm="find . -name "node_modules" -type d -prune -exec rm -rf '{}' +"

# ecli
export GOOGLE_APPLICATION_CREDENTIALS=${HOME}/.ecli/engineering11-cli.json

# diff
cdiff() {
  if [ $# -lt 2 ]; then
    echo "Needs at least 2 args" >&2
    return 1
  fi
  left="$1"
  right="$2"
  shift 2
  diff -u "$right" "$left" "$@" | diff-so-fancy
}

# yarn
alias yarnroot='eval "cd $(${HOME}/bin/yarnroot/yarnroot)"'

