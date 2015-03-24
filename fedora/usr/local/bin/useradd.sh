#!/bin/bash

# Setup
ancillary=
histchars=
groups=()

# Options
while getopts opt "G:n:u:p:"; do
  case "$opt" in
    G) groups+=("$OPTARG");;
    n) DESIRED_USER="$OPTARG";;
    u) DESIRED_UID="$OPTARG";;
    p) DESIRED_PASSWORD="$OPTARG";;
  esac
done
shift $(( $OPTIND - 1 ))
OPTIND=0

# Functions
usage() {
  echo "Usage: useradd.sh -u UID -n USERNAME -p PASSWORD -G GROUP1 [-G GROUP2 ... -G GROUPN]" >&2
}

# Validation
[ -z "$DESIRED_USER" ] && usage && exit 1
[ -z "$DESIRED_UID" ] && usage && exit 1
[ -z "$DESIRED_PASSWORD" ] && usage && exit 1

# Add groups that actually already exist
for gz in "${groups[@]}"; do
  id -g $gz
  if [ $? -eq 0 ]; then
    if [ ${#ancillary} -eq 0 ]; then
      ancillary=$gz
    else
      ancillary="$ancillary,$gz"
    fi
  fi
done

# Make it so!
# TODO: detect username collision, too
id -u $DESIRED_UID
if [ $? -eq 0 ]; then
  echo -e "\nAborting! uid collision\n"
elif [ ${#ancillary} -eq 0 ]; then
  echo -e "\nAborting! No ancillary groups found!\n"
else
  echo -e "\nUsing ancillary groups: $ancillary\n"
  useradd -u $DESIRED_UID -G $ancillary $DESIRED_USER
  echo "$DESIRED_PASSWORD" | passwd --stdin $DESIRED_USER
fi

