
#
# Perforce functions
#

. /etc/profile.d/net.sh

export P4_HOME="${P4_HOME:-/opt/p4}"
export P4NAME="${P4NAME:-$MACHINENAME}"
export P4NODE="${P4NODE:-$MACHINENAME}"
export P4PORT="${P4PORT:-vscm01:1666}"
export P4USER="${P4USER:-$USER}"
export P4CLIENT=${P4USER}-${P4NAME}

if [ "Cygwin" = "`uname -o`" ]; then
  export P4EDITOR="`cygpath -aw /usr/bin/vim.exe`"
else
  export P4EDITOR=/usr/bin/vim
fi

pathadd "$P4_HOME" "Perforce"

# Has realpath installed?
declare -xi FLAG_REALPATH=0
which realpath > /dev/null 2>&1
FLAG_REALPATH=$?

# ---------------------------------------------------------------------
#   Private functions 
# ---------------------------------------------------------------------

#
# Print a variable name, value, and source.
#
# Arguments:
#   1 - Required. name
#   2 - Required. value
#   3 - Required. source
#
function printgrabsrc()
{
  echo "Pulled $1=$2 from $3." >&2
}

function p4-revert-changelist()
{
  local cl="$1"
  local files=$(p4 describe ${cl} | awk -f /usr/local/p4-files-in-changelist.awk)
  p4 revert -c ${cl} ${files}
}

#
# Grab the current P4 user in order of precedence:
#   1) environment
#   2) Windows Registry
#   3) p4 configure
#   4) current OS login name
#
function grabp4user()
{
  p4u="$P4USER"
  if [ -z "$p4u" ]; then
    p4u=`p4 set | grep -P -o '(?<=P4USER=)\w+'`
    if [ -z "$p4u" ]; then
      p4u=`p4 configure show | grep -P -o '(?<=P4USER=)\w+'`
      if [ -z "$p4u" ]; then
        p4u="$USER"
        printgrabsrc P4USER $p4u "OS user"
      else
        printgrabsrc P4USER $p4u configure
      fi
    else
      printgrabsrc P4USER $p4u registry
    fi
  else
    printgrabsrc P4USER $p4u environment
  fi
}

# ---------------------------------------------------------------------
#   Public functions 
# ---------------------------------------------------------------------

#
# Crete a new changelist with given description.
#
# Arguments:
#   1 - Required. Description for new changelist
#
function p4-new-changelist()
{
  if [ "$1x" = "x" ]; then
    echo "No changelist description given!" >&2
    return 1
  fi
  echo $(p4 change -o | sed 's/<enter description here>/'"$1"'/g' | p4 change -i | cut -d ' ' -f 2)
}

#
# Intelligently add a new file to the depot if it doesn't exist, otherwise edit it.
#
# Arguments:
#   1 - Required. Changelist number
#   2 - Required. File to add/edit
#
function p4-add-or-edit()
{
  if [ "$1x" = "x" ]; then
    echo "No changelist# given!" >&2
    return 1
  fi

  if [ "$2x" = "x" ]; then
    echo "No filespec given!" >&2
    return 1
  fi

  local _cl="$1"
  local _file="$2"

  p4 files "$_file" 2>&1 | grep 'no such file'
  if [ $? -eq 0 ]; then
    p4 add -c "$_cl" "$_file"
    return $?
  else
    p4 edit -c "$_cl" "$_file"
    return $?
  fi

  return 0
}

#
# Perform intelligent login (if needed), showing the username attempting to login
# and where the username was derived from.
#
function p4login()
{
  _cap=$(command p4 "$@" login -s 2>&1)
  if [ $? -gt 0 ]; then
   grabp4user
    stty -echo
    command p4 "$@" login
    stty echo
  else
    echo "$_cap" >&2
  fi
}

#
# p4 "alias" normalizing symlinks so p4 executable can understand.
# Also performs intelligent login.
#
# Options:
#   passthrough: p4 executable
#
# Arguments:
#   passthrough: p4 executable
#
function p4() 
{
  # Change to real file for debugging
  local _log=~/p4.log

  # Wrangle original options
  declare -a original
  while getopts ":b:c:d:GH:p:P:su:x:C:Q:L:z:Vh" opt; do
    case "$opt" in
      *) original+=("-$opt")
         if [[ $OPTARG ]]; then
           original+=("$OPTARG")
         fi 
         unset OPTARG
         ;;
    esac
  done
  echo "\$optind=$OPTIND" >> $_log 2>&1
  shift $(( $OPTIND - 1 ))
  OPTIND=0
  echo "\$1=$1" > $_log 2>&1
  echo "original#${#original[@]}=${original[@]}" >> $_log 2>&1
  echo "pos=$@" > $_log 2>&1
  
  # Opted for intelligent login. Matched "p4 [g-opts] login"
  if [[ "$1" = "login" ]] && [[ ${#*} -eq 1 ]]; then
    echo "Special login" >> $_log 2>&1
    p4login "${original[@]}"
  else
    # Cygwin variant
    if [ "Cygwin" = `uname -o` ]; then
      command p4 -d `cygpath -aw .` "${original[@]}" "$@"
    else
      # With realpath
      if [[ $FLAG_REALPATH -eq 0 ]]; then
        echo "realpath used." >> $_log 2>&1
        command p4 -d `realpath "$PWD"` "${original[@]}" "$@"
      # Without realpath
      else
        command p4 "${original[@]}" "$@"
      fi
    fi
  fi
}
