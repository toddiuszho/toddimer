#!/bin/bash
function toggle-proxy()
{
  capture=$(/C/tools/toggle-proxy.cmd $@)
  echo "$capture"
#  off=$(echo "$capture" | grep "OFF" | wc -l)
#  if [ "$off" = "1" ]; then
#    reroute
#  else
#    reroute -d
#  fi
}

function opensesame()
{
#  ssh -D 12345 -f -N -c arcfour web3
  /usr/local/bin/proxy &
}

function closesesame()
{
  local PIDFILE=/var/run/opensesame.pid
  if [ -f $PIDFILE ]; then
    local pid=$(cat $PIDFILE)
    ps | awk '{print $1 "-" $2 "-"}' | grep -Po "\d+(?=-$pid-)" | xargs kill -9 $pid
    rm $PIDFILE
  fi
}

