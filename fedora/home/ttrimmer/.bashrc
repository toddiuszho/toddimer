# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific aliases and functions
export LC_TMUX_SESSION_NAME="${USER}"
if [ -n "$LC_TMUX_SESSION_NAME" -a $TERM != "screen" ]; then
  DOMAINLESS="${HOSTNAME%%.*}"
  IDLESS="${DOMAINLESS#[0-9][0-9][0-9][0-9][0-9][0-9]-}"
  echo -ne "\033]0;"${IDLESS}"\007"  # Set terminal title
  session_name=$LC_TMUX_SESSION_NAME
  tmux has-session -t "${LC_TMUX_SESSION_NAME}" && tmux attach-session -t "${LC_TMUX_SESSION_NAME}" || tmux new-session -s "${LC_TMUX_SESSION_NAME}"
fi

