#!/bin/bash

#
# table.sh
#
# ASCII table formatting functions.
#


#
# Generate column lines for footers/headers
#
# Arguments:
#   1  -- character to create lines with
#   2+ -- column lengths
#
function table-line()
{
  local ch="$1"
  shift 1
  declare -i index=1
  for colWidth in $@; do
    for i in `seq 1 $colWidth`; do
      echo -n "$ch"
    done
    if [ $index -lt $# ]; then
      echo -ne "\t"
    fi
    index=$(( $index + 1 ))
  done
  echo ""
  unset i
  unset colWidth
  unset index
}


#
# Print header row
#
# Arguments:
#  1  -- reference to array of column formats
#  2+ -- header values
#
function table-header()
{
  local fmts="$1"
  shift 1
  local sGrandFmt=""
  local tail=""
  local nFmt=$(eval echo \${#${fmts}[@]})
  local lastPos=$(( $nFmt - 1 ))
  for i in `seq 0 $lastPos`; do
    tail=$(eval echo \${${fmts}[$i]})
    if [ $i -eq 0 ]; then
      sGrandFmt="%${tail}s"
    else
      sGrandFmt="${sGrandFmt}\t%${tail}s"
    fi
  done
  unset i
  sGrandFmt="${sGrandFmt}\n"
  printf "$sGrandFmt" "$@"
}


#
# Print table row
#
# Options:
#   -H    flag that row header is already printed
# Arguments:
#   1  -- reference to column formats
#   2+ -- row values
#
function table-row()
{
  declare -i use_row_header=0
  while getopts "H" opt; do
    case "$opt" in
      H) use_row_header=1
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0

  local fmts="$1"
  shift 1
  local sGrandFmt=""
  local tail=""
  local nFmt=$(eval echo \${#${fmts}[@]})
  local lastPos=$(( $nFmt - 1 ))
  for i in `seq $use_row_header $lastPos`; do
    tail=$(eval echo \${${fmts}[$i]})
    if [ $i -eq $use_row_header ]; then
      sGrandFmt="$tail"
    else
      sGrandFmt="$sGrandFmt\t$tail"
    fi
  done
  unset i
  sGrandFmt="${sGrandFmt}\n"
  #if [ $use_row_header -eq 1 ]; then
  #  echo -e "\n-----"
  #  echo sGrandFmt=$sGrandFmt
  #  echo -e "\n-----"
  #fi
  printf "$sGrandFmt" "$@"
}


#
# Print a row header
#
# Arguments:
#   1 -- format of row header
#   2 -- value of row header
#
function table-row-header()
{
  printf "%$1s\t" "$2"
}
