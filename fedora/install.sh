#!/bin/bash
SRCROOT=$(dirname "$0")
! [ -e $HOME/bin ] && mkdir $HOME/bin
cp $SRCROOT/home/ttrimmer/.bash* $HOME/
cp -f $SRCROOT/home/ttrimmer/.vim* $HOME/
cp $SRCROOT/home/ttrimmer/bin/* $HOME/bin/
