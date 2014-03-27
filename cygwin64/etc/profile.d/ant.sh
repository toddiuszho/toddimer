#!/bin/bash

export ANT_HOME=${ANT_HOME:-"/opt/ant/default"}
pathadd "$ANT_HOME/bin" "Ant"

function ant()
{
  command ant -logger org.apache.tools.ant.listener.AnsiColorLogger "$@" 2>&1 | sed 's/2;//g' ;
}
