#!/bin/bash

#
# Twiddle library
#

export TWIDDLE_HOME="${TWIDDLE_HOME:-/opt/twiddle}"

function twiddle-get()
{
  local log="$1"
  shift 1
  echo $("$TWIDDLE_HOME/bin/widdle" -q get --noprefix "$@" 2>"$log" | tr -d "\r\n")
}

function twiddle-verify()
{
  if
    verify_specified_directory "TWIDDLE_HOME" "$TWIDDLE_HOME" && \
    verify_specified_directory "TWIDDLE_HOME/bin" "$TWIDDLE_HOME/bin" && \
    verify_specified_executable "TWIDDLE_HOME/bin/twiddle.sh" "$TWIDDLE_HOME/bin/twiddle.sh" && \
    verify_specified_executable "TWIDDLE_HOME/bin/widdle" "$TWIDDLE_HOME/bin/widdle"
  then
    return 0
  else
    return 1
  fi
}
