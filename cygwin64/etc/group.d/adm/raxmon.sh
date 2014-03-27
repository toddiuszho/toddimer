#!/bin/bash

export RAXMON_LOG="${RAXMON_LOG:-/dev/null}"

raxmon-exec() {
  local category="$1"
  local op="$2"
  raxmon_options=()
  local bCap=1
  local sCap=""
  local opt=""
  for i in `seq 3 $#`; do
    opt="${!i}"
    if [ "$opt" = '-' ]; then
      bCap=0
      continue
    fi

    if [ $bCap -eq 0 ]; then
      sCap="$opt"
    else
      raxmon_options+=("$opt")
    fi
  done

  echo "category=$category" >$RAXMON_LOG
  echo "op=$op" >$RAXMON_LOG
  echo "raxmon_options=${raxmon_options[@]}" >$RAXMON_LOG
  echo "bCap=$bCap" >$RAXMON_LOG
  echo "sCap=$sCap" >$RAXMON_LOG

  local EXEC=raxmon-$category-$op
  local fp="`which $EXEC`"
  if [ $? -ne 0 ]; then
    echo "$EXEC is not a real executable!" >&2
    return 1
  fi
  if ! [ -x "$fp" ]; then
    echo "$fp is not executable by $USER!" >&2
    return 1
  fi

  if [ $bCap -eq 0 ]; then
    if [ -z "$sCap" ]; then
      $EXEC "${raxmon_options[@]}" | grep -Po --color=no '(?<=\bid=)\w+'
    else
      $EXEC "${raxmon_options[@]}" | grep --color=no "$sCap" | grep -Po --color=no '(?<=\bid=)\w+'
    fi
  else
    $EXEC "${raxmon_options[@]}"
  fi
}

raxmon-alarm() {
  local name="$1"
  local action="$2"
  local entityId=`raxmon-exec entities list - $name`
  raxmon_alarms=(`raxmon-exec alarms list --entity-id="$entityId" -`)
  echo "$action ${#raxmon_alarms[@]} alarms on $name ..."
  for thisAlarm in "${raxmon_alarms[@]}"; do
    raxmon-exec alarms $action --entity-id="$entityId" --id="$thisAlarm"
  done
}

