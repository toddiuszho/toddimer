# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

#
# Uncomment lines below for auto-tmux support
#declare -i doTmux=0
#export LC_TMUX_SESSION_NAME="${USER}"
#if [ -n "$LC_TMUX_SESSION_NAME" -a $TERM != "screen" -a $doTmux -eq 0 ]; then
#  DOMAINLESS="${HOSTNAME%%.*}"
#  IDLESS="${DOMAINLESS#[0-9][0-9][0-9][0-9][0-9][0-9]-}"
#  echo -ne "\033]0;"${IDLESS}"\007"  # Set terminal title
#  tmux has-session -t "${LC_TMUX_SESSION_NAME}" > /dev/null 2>&1 && tmux attach-session -t "${LC_TMUX_SESSION_NAME}" || tmux new-session -s "${LC_TMUX_SESSION_NAME}"
#fi

