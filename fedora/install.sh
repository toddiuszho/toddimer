#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
  echo "Aborting! OSX" >&2
  exit 1
fi
SRCROOT=$(dirname "$0")
! [ -e $HOME/bin ] && mkdir $HOME/bin
cp $SRCROOT/home/ttrimmer/.bash* $HOME/
cp -f $SRCROOT/home/ttrimmer/.vim* $HOME/
cp $SRCROOT/home/ttrimmer/bin/* $HOME/bin/
