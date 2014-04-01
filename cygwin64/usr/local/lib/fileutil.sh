#!/bin/bash

#
# fileutil.sh
#
# file utiity functions
#

function verify_specified_directory()
{  
  local name="$1"
  local path="$2"
  
  if [ -z "$path" ]; then
    echo "$name is an empty string or not set!" >&2
    return 10
  fi
  
  if ! [ -e "$path" ]; then
    echo "$name [$path] does not exist!" >&2
    return 20
  fi
  
  if ! [ -d "$path" ]; then
    echo "$name [$path] is not a directory!" >&2
    return 30
  fi
  
  if ( ! [ -r "$path" ] ) || ( ! [ -x "$path" ] ); then
    echo "$name [$path] cannot be listed!" >&2
    return 40
  fi
  
  return 0
}

function verify_specified_executable()
{  
  local name="$1"
  local path="$2"
  
  if [ -z "$path" ]; then
    echo "$name is an empty string or not set!" >&2
    return 10
  fi
  
  if ! [ -e "$path" ]; then
    echo "$name [$path] does not exist!" >&2
    return 20
  fi
  
  if ! [ -f "$path" ]; then
    echo "$name [$path] is not a file!" >&2
    return 30
  fi
  
  if ( ! [ -r "$path" ] ) || ( ! [ -x "$path" ] ); then
    echo "$name [$path] cannot be executed!" >&2
    return 40
  fi
  
  return 0
}

function updateifdiff()
{
  while getopts "d:g:o:m:s:u:" opt; do
    case "$opt" in
      d) _DEST="$OPTARG";;
      g) _GROUP="$OPTARG";;
      o) _OWNER="$OPTARG";;
      m) _MODE="$OPTARG";;
      s) _SOURCE="$OPTARG";;
      u) _USER="$OPTARG";;
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0

  # Check dest
  if [ -z "$_DEST" ]; then
    echo "Need a destination!" >&2
    unset _SOURCE
    return 1
  fi

  # Need either -s or -u or THAT_P4_USER
  if [ -z "$_SOURCE" ] && [ -z "$_USER" ] && [ -z "$THAT_P4_USER" ]; then
    echo "Need either source (-s DIR), user (-u USER), or THAT_P4_USER from environment!" >&2
    unset _SOURCE
    return 1
  fi

  # Need either -u or THAT_P4_USER
  if [ -z "$_USER" ] && [ -z "$THAT_P4_USER" ]; then
    echo "No user (-u USER) or THAT_P4_USER from environment!" >&2
    unset _SOURCE
    return 1
  fi

  _MODE="${_MODE:-775}"
  _OWNER="${_OWNER:-root}"
  _GROUP="${_GROUP:-root}"
  _USER="${_USER:-$THAT_P4_USER}"
  _SOURCE="${_SOURCE:-/home/$_USER/depot/enterprise}"

  # Verify explicit or derived source
  if ! [ -d "$_SOURCE" ]; then
    echo "Source [$_SOURCE] is not a directory!" >&2
    unset _SOURCE
    return 1
  fi

  declare -i copyit=1
  declare -a opts=()

  # Options for Cygwin
  if [ `uname -o` = "Cygwin" ]; then
    opts+="-T"
  fi

  cd "$_SOURCE"
  for file in "$@"; do
    copyit=1
    short=${file##*/}
    if [ -e $_DEST/$short ]; then
      diff "$file" "$_DEST/$short" 2>&1 > /dev/null
      copyit=$?
    fi
    if [ $copyit -ne 0 ]; then
      echo "Updating: $short" >&2
      install --owner="$_OWNER" --group="$_GROUP" --mode="$_MODE" "${opts[@]}" "$file" "$_DEST/$short"
    fi
  done
  unset file
  unset _DEST
  unset _GROUP
  unset _OWNER
  unset _MODE
  unset _SOURCE
  unset _USER
}

function removeifexists()
{
  for file in "$@"; do
    if [ -e "$file" ]; then
      \rm -f "$file"
    fi
  done
}

