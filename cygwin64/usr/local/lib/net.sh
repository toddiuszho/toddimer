#!/bin/bash

#
# Networking functions
#

#
# Convert a CIDR to a netmask
#
# Arguments:
#   1  - part past the /
# 
cidr2mask() {
  local i mask=""
  local full_octets=$(( $1/8 ))
  local partial_octet=$(( $1%8 ))

  for ((i=0;i<4;i+=1)); do
    if [ $i -lt $full_octets ]; then
      mask+=255
    elif [ $i -eq $full_octets ]; then
      mask+=$(( 256 - 2**(8-$partial_octet) ))
    else
      mask+=0
    fi  
    test $i -lt 3 && mask+=.
  done

  echo "$mask"
}

#
# Calculates number of bits n a netmask
#
# Arguments:
#  1  - netmask (255.255.0.0)
#
mask2cidr() {
  nbits=0
  OLD_IFS="$IFS"
  IFS="."
  for dec in "$1" ; do
    case "$dec" in
      255) let nbits+=8;;
      254) let nbits+=7 ; break ;;
      252) let nbits+=6 ; break ;;
      248) let nbits+=5 ; break ;;
      240) let nbits+=4 ; break ;;
      224) let nbits+=3 ; break ;;
      192) let nbits+=2 ; break ;;
      128) let nbits+=1 ; break ;;
      0);;
      *) echo "Error: $dec is not recognised" >&2; IFS="$OLD_IFS"; return 1
    esac
  done
  echo "$nbits"
  IFS="$OLD_IFS"
}

