#!/bin/bash

export JMETER_HOME="${JMETER_HOME:-/C/jmeter}"

function jmeter()
{
  cd "$JMETER_HOME/bin"
  jmeter.sh 2>&1 > /dev/null &
}
