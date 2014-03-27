#!/bin/bash

#
# MySQL functions
#

#
# Load MySQL script
#
# Options
#   d - schema name to load script into
#   f - defaults-file for permissions
#
# Arguments
#   1 -- dbscript path
#   2 -- Optional. name of outer calling script
#
function mysql-load()
{ 
  # Options
  while getopts ":d:f:" opt; do
    case "$opt" in
      d) local db=$OPTARG;;
      f) local _file="$OPTARG";;
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0

  local dbscript="$1"
  local outerFunctionName="${2:-mysql-load}"
  local usage="Usage: $outerFunctionName -f DEFAULTSFILE -d SCHEMA SCRIPTFILE [FUNCNAME]"
  
  # Validate script
  if ! [[ $dbscript ]]; then
    echo "No script passed in!" >&2
    echo "$usage" >&2
    return 1
  fi
  if ! [ -f $dbscript ]; then
    echo "Cannot find script file: $dbscript" >&2
    return 1
  fi
  
  # Validate db
  if ! [[ $db ]]; then
    echo "No database name was passed in!" >&2
    echo "$usage" >&2
    return 1
  fi
  
  # Validate defaults-file
  if ! [[ $_file ]]; then
    echo "No defaults file was passed in!" >&2
    echo "$usage" >&2
    return 1
  fi
  if ! [ -f $_file ]; then
    echo "Cannot find defaults file: $_file" >&2
    return 1
  fi
  
  # Launch!
  echo "Loading script $dbscript into schema $db." >&2
  mysql --defaults-file="$_file" $db < "$dbscript"
}

#
# Execute MySQL statement
#
# Options
#   d - schema name to load script into
#   f - defaults-file for permissions
#
# Arguments
#   1 - statement to execute
#   2 - Optional. name of outer calling script
#
function mysql-exec()
{
  # Options
  while getopts ":d:f:" opt; do
    case "$opt" in
      d) local db=$OPTARG;;
      f) local _file="$OPTARG";;
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0
  
  local stmt="$1"
  local outerFunctionName="${2:-mysql-exec}"
  local usage="Usage: $outerFunctionName -f DEFAULTSFILE -d SCHEMA STMT [FUNCNAME]"

  # Validate db
  if ! [[ $db ]]; then
    echo "No database name was passed in!" >&2
    echo "$usage" >&2
    return 1
  fi
  
  # Validate defaults-file
  if ! [[ $_file ]]; then
    echo "No defaults file was passed in!" >&2
    echo "$usage" >&2
    return 1
  fi
  if ! [ -f $_file ]; then
    echo "Cannot find defaults file: $_file" >&2
    return 1
  fi
  
  #Validate stmt
  if ! [[ $stmt ]]; then
    echo "No statement was passed in!" >&2
    echo "$usage" >&2
    return 1
  fi
  
  # Launch!
  echo "Executing statement [$stmt] into schema $db." >&2
  mysql --defaults-file="$_file" $db -e "$stmt"
}

#
# Create new schema
#
# Options
#   d - schema name to create
#   f - defaults-file for permissions
#
# Arguments
#   1 - Optional. name of outer calling script
#
function mysql-create-schema()
{
  # Options
  while getopts ":d:f:" opt; do
    case "$opt" in
      d) local db=$OPTARG;;
      f) local _file="$OPTARG";;
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0
  
  local outerFunctionName="${1:-mysql-create-schema}"
  local usage="Usage: $outerFunctionName -f DEFAULTSFILE -d SCHEMA [FUNCNAME]"

  # Validate db
  if ! [[ $db ]]; then
    echo "No database name was passed in!" >&2
    echo "$usage" >&2
    return 1
  fi
  
  # Validate defaults-file
  if ! [[ _$file ]]; then
    echo "No defaults file was passed in!" >&2
    echo "$usage" >&2
    return 1
  fi
  if ! [ -f $_file ]; then
    echo "Cannot find defaults file: $_file" >&2
    return 1
  fi
  
  # Launch!
  echo "Creating schema $db if it doesn't exist." >&2
  mysql --defaults-file="$_file" mysql -e "CREATE SCHEMA IF NOT EXISTS $db"
}
