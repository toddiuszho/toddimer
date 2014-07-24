
#
# _.sh: Directory and path aliases and functions
#

# Load  machine specific overrides first, if it exists
if [ -f /etc/profile.d/machine-conf.sh ]; then
  . /etc/profile.d/machine-conf.sh
fi

if [ 'Cygwin' = `uname -o` ]; then
  export USERHOME="`cygpath -au $USERPROFILE`"
else
  export USERHOME="$USERPROFILE"
fi

# Directory aliases
alias d='ls -FlaGh --color'
alias dg='ls -Fla --color'

#
# Core function for adding directories to PATH
#
# Options:
#   -f force adding to path even if already there
#   -s add to start instead of end, but still allow '.' to be first
#
# Arguments:
#   1 -- Required. Directory path to add to PATH if not already there
#   2 -- Required. Debugging description for what is trying to be added
#
function pathadd() {
#  local log=/var/log/pathadd.log
  local log=/dev/null
  declare -i _force=0
  declare -i _start=0
  declare -i _there=0
  while getopts "fs" opt; do
    case "$opt" in
      f) _force=1;;
      s) _start=1;;
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0
  echo "Adding $2." >> $log
  if [ -d "$1" ]; then
    if [[ ":$PATH:" == *":$1:"* ]]; then
      _there=1
    fi
    if [ $_force -eq 1 ] || [ $_there -eq 0 ]; then
      if [ $_start -eq 0 ]; then
        echo "Adding $2 to end." >> $log
        PATH="$PATH:$1"
      else
        if [ "$1" = "." ]; then
          echo "Adding $2 to absolute beginning." >> $log
          PATH="$1:$PATH"
        else
          if [ "$PATH" = "." ]; then
            PATH=".:$1"
          else
            if [ "$PATH" = "${PATH#.:}" ]; then
              PATH="$1:$PATH"
            else
              PATH=".:$1:${PATH#.:}"
            fi
          fi
#         parts=$(echo "$PATH" | tr ':' "\n")
#         parts=($parts)
#         len=${#parts[@]}
#         if [ $len -eq 0 ]; then
#           echo "Pre-existing PATH is empty, so setting whole PATH to $1." >> $log
#           PATH="$1"
#         else
#           if [ "${parts[0]}" = '.' ]; then
#             echo "Detected CWD on PATH, so adding $2 to just after it." >> $log
#             PATH=".:$1"
#             declare -i i=1
#             while [ $i -lt $len ]; do
#               PATH="$PATH:${parts[$i]}"
#               i=$(( $i + 1 ))
#             done
#           else
#             echo "CWD was not on PATH, so adding $2 to absolute beginning." >> $log
#             PATH="$1:$PATH"
#           fi
#         fi
        fi
      fi
    else
      echo "Could not add $2 since $1 is already on the path and was not forced." >> $log
    fi
  else
    echo "Could not add $2 since $1 is not a directory." >> $log
  fi
}

# Assure /usr/local/bin is on PATH
pathadd /usr/local/bin "local binaries"

# Assure CWD overrides
pathadd -s '.' "CWD"

