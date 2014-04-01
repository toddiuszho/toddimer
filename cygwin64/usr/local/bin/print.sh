#!/bin/bash

#
# print.sh: function library for color messages
#

function printfailure()
{
    echo -e "[\e[1;31m$1\e[00m]"
}

function printsuccess()
{
    echo -e "[\e[1;32m$1\e[00m]"
}

function printwarning()
{
    echo -e "[\e[1;33m$1\e[00m]"
}

