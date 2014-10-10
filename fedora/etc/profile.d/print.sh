
#
# print.sh: function library for color messages
#

function printfailure()
{
  local banner="FAILED"
  while getopts "b:" opt; do
    case "$opt" in
      b) banner="$OPTARG";;
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0
  echo -e "[\e[1;31m$banner\e[00m] $@" >&2
}

function printsuccess()
{
  local banner="SUCCESS"
  while getopts "b:" opt; do
    case "$opt" in
      b) banner="$OPTARG";;
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0
  echo -e "[\e[1;32m$banner\e[00m] $@" >&2
}

function printwarning()
{
  local banner="WARNING"
  while getopts "b:" opt; do
    case "$opt" in
      b) banner="$OPTARG";;
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0
  echo -e "[\e[1;33m$banner\e[00m] $@" >&2
}

printlabel() {
  if [ $# -gt 1 ]; then
    echo -e $1 "\e[35m$2:\e[0m"
  else
    echo -e "\e[35m$1:\e[0m"
  fi
}

