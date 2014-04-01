#!/bin/bash

#
# imports.sh
#
# Library for importing other libraries and profile scripts into OTHER
# libraries and profile scripts
#

function imports() {
    local parent="$1"
    shift 1
    for file in "$@"; do
        if [ -e ${parent}/${file}.sh ]; then
            source ${parent}/${file}.sh
        else
            echo "Cannot import [${parent}/${file}.sh]!" >&2
        fi
    done
    unset file
}

function lib_imports() {
    imports "/usr/local/lib" "$@"
}

function profile_imports() {
    imports "/etc/profile.d" "$@"
}

function group_imports() {
    local parent="/etc/group.d/$1"
    shift 1
    imports "${parent}" "$@" 
}