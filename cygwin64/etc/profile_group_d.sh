#!/bin/bash

# Load functions/aliases for all of users groups
function group_d()
{
  # root loads all groups
  if [ `/usr/bin/id -u` -eq 0 ]; then
    for group in `LC_COLLATE=C ls -1 /etc/group.d`; do
      grppath="/etc/group.d/${group}"
      if [ -e "${grppath}" ] && [ -d "${grppath}" ]; then
        for file in `LC_COLLATE=C ls -1 ${grppath}/*.${1}`; do
          source $file
        done
      fi
    done
  # non-root only loads his groups
  else
    for group in `/usr/bin/groups`; do
      grppath="/etc/group.d/${group}"
      if [ -e "${grppath}" ] && [ -d "${grppath}" ]; then
        for file in `LC_COLLATE=C ls -1 ${grppath}/*.${1}`; do
          source $file
        done
      fi
    done
    unset group
    unset grppath
  fi
  unset file
}

