#!/bin/bash

declare -i echo_only=1 do_resume=1 do_suspend=1

while getopts "ers" opt; do
  case $opt in
    e) echo_only=0;;
    r) do_resume=0;;
    s) do_suspend=0;;
  esac
done
OPTIND=0

if [ $do_resume -eq 0 ] && [ $do_suspend -eq 0 ]; then
  echo "Cannot both suspend and resume" >&2
  exit 1
fi

if [ $do_resume -eq 1 ] && [ $do_suspend -eq 1 ]; then
  echo "Must suspend or resume" >&2
  exit 1
fi

if [ $do_resume -eq 0 ]; then
  action=resume
elif [ $do_suspend -eq 0 ]; then
  action=suspend
fi

grps=($(aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[].AutoScalingGroupName' --output text))
NEEDLE=${NEEDLE:-Prod-SqsWorker}

for grp in ${grps[@]}; do
  zap="${grp#$NEEDLE}"
  if [ "${grp}" != "${zap}" ]; then
    echo -e "\033[35m${grp}\033[0m"
    s_cmd="aws autoscaling ${action}-processes --auto-scaling-group-name \"${grp}\" --scaling-processes Launch"
    if [ $echo_only -eq 0 ]; then
      echo $s_cmd
    else
      eval "${s_cmd}"
    fi
    echo ''
  fi
done
