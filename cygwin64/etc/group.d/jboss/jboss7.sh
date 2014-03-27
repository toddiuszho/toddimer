#!/bin/bash

export JBOSS_HOME="${JBOSS_HOME:-/opt/jboss/jboss7}"
export JBOSS_HOME_PATH=`realpath "$JBOSS_HOME"`
export JBOSS_HOME_VFS="$JBOSS_HOME_PATH"

if [[ "Cygwin" = `uname -o` ]]; then
  JBOSS_HOME_PATH=`cygpath -aw "$JBOSS_HOME_PATH"`
  JBOSS_HOME_VFS="$JBOSS_HOME_PATH"
  JBOSS_HOME_VFS=/${JBOSS_HOME_VFS//\\//}
fi

export JBOSS_JNI_PORT="${JBOSS_JNI_PORT:-1099}"
export JBOSS_LOGGING='jboss.system:type=Log4jService,service=Logging'
export JBOSS_WEB_PORT="${JBOSS_WEB_PORT:-8080}"

# ---------------------------------------------------------------------
#   Private Functions
# ---------------------------------------------------------------------

#
# Parse options for public functions
#
# Arguments:
#   @ -- pass in all arguments from a public function to set internal flags
#
function jboss7-opts() {
  # reset to defaults 
  JBOSS_CONF="${JBOSS_DEFAULT_CONF:-default}"
  declare -i _setBIND=1
  declare -xa opts=()
  SUBIT="sudo -u jboss"
  if [[ 'Cygwin' = `uname -o` ]]; then
    SUBIT=""
  fi
  
  # parse options
  while getopts ":b:c:" opt; do
    case "$opt" in
      b) JBOSS_BIND="$OPTARG"; 
         _setBIND=0;
         opts+="-b";
         opts+="$OPTARG";
         ;;
      c) JBOSS_CONF="$OPTARG";
         opts+='c';
         opts+="$OPTARG";
         if ! [[ ${JBOSS_CONFS[$JBOSS_CONF]} ]]; then
           printwarning "BAD CONFIG" "Unrecognized configuration: $JBOSS_CONF. Please check JBOSS_CONFS in /etc/profile" >&2
         fi
         ;;
    esac
  done
  
  # If not explicity set, retrieve BIND from assoc. array or dev default
  if [[ $_setBIND -eq 1 ]]; then
    if [[ ${!JBOSS_CONFS[@]} ]]; then
      JBOSS_BIND="${JBOSS_CONFS[$JBOSS_CONF]}"
    else
      JBOSS_BIND="0.0.0.0"
    fi
  fi
  
  # Set listen
  JBOSS_LISTEN="$JBOSS_BIND"
  if [[ "$JBOSS_LISTEN" = "0.0.0.0" ]]; then
    JBOSS_LISTEN="${JBOSS_LISTEN_OVERRIDE:-127.0.0.1}"
  fi
  
  # reset state and let parent function know how many options were parsed
  declare -i prevOPTIND=$OPTIND
  OPTIND=0
  return $prevOPTIND
}

# ---------------------------------------------------------------------
#   Public Functions
# ---------------------------------------------------------------------

# -- Service --

function jboss7-start() {
  jboss7-opts $@
  echo "Starting node $JBOSS_CONF at $JBOSS_BIND ..." >&2
  cd "${JBOSS_HOME}/standalone/log"
  $SUBIT "$JBOSS_HOME/bin/standalone.sh" -b $JBOSS_BIND -bmanagement $JBOSS_BIND > /dev/null 2>&1 &
}

function jboss7-start-console() {
  jboss7-opts $@
  echo "Starting node $JBOSS_CONF at $JBOSS_BIND ..." >&2
  $SUBIT "$JBOSS_HOME/bin/standalone.sh" -b $JBOSS_BIND -bmanagement $JBOSS_BIND
}

function jboss7-stop() {
  jboss7-opts $@
  $SUBIT $JBOSS_HOME/bin/jboss-cli.sh --connect :shutdown
}

# -- Misc. --

function jboss7-debug() {
  jboss7-opts $@
  echo "JBoss Debug"
  echo "==========="
  echo ""
  echo "Configuration"
  echo "-------------"
  
  echo "Shell variables:"
  echo "  JBOSS_CONF=$JBOSS_CONF"
  echo "  JBOSS_DEFAULT_CONF=${JBOSS_DEFAULT_CONF:-<not set>}"
  echo "  JBOSS_BIND=$JBOSS_BIND"
  echo "  JBOSS_LISTEN=$JBOSS_LISTEN"
  echo "  JBOSS_LISTEN_OVERRIDE=${JBOSS_LISTEN_OVERRIDE:-<not set>}"
  echo ""
    
  if [[ ${!JBOSS_CONFS[@]} ]]; then
    echo "Configured associative array JBOSS_CONFS:"
    for key in ${!JBOSS_CONFS[@]}; do echo "  $key=${JBOSS_CONFS[$key]}"; done
  else 
    echo "Associative array JBOSS_CONFS not set."
  fi
  echo "/----"
  echo ""
  echo "/===="
}

function jboss7-help() {
  echo "JBoss 7 Help" >&2
  echo "----------" >&2
  echo "" >&2
  echo "Common Options:" >&2
  echo "  -b                      bind address (use sparingly)" >&2
  echo "" >&2
  echo "Service Functions:" >&2
  echo "  jboss7-cli              CLI management" >&2
  echo "  jboss7-help             This help screen" >&2
  echo "  jboss7-start            Start node as service" >&2
  echo "  jboss7-start-console    Start node in console" >&2
  echo "  jboss7-stop             Stop node" >&2
  echo "" >&2
  echo "Logging Functions:" >&2
  echo "  jboss7-setLoggerLevel   Set Log4J logger" >&2
  echo "                          1: logger name" >&2
  echo "                          2: logging level" >&2
  echo "                          NOT CURRENTLY SUPPORTED!" >&2
  echo "  jboss7-tailsrv          Follow server log" >&2
  echo "  jboss7-visrv            Edit server log" >&2
  echo "" >&2
  echo "Configuration:" >&2
  echo "  -- /etc/profile.d/machine-conf.sh" >&2
  echo "     Populate JBOSS_CONFS with node names as keys and bind addresses as values." >&2
  echo "     This allows you to invoke most commands with the node name using the -c option." >&2
  echo "     If JBOSS_CONFS is commented out, it assumes a single node of [default]=0.0.0.0" >&2
}

function jboss7-cli {
  jboss7-opts $@
  shift $(( $? - 1 )) 
  $SUBIT "$JBOSS_HOME/bin/jboss-cli.sh" --connect $@
}

# --- Logging ---

function jboss7-setLoggerLevel() {
  echo "Not supported!" >&2
  #jboss7-opts $@
  #shift $(( $? - 1 )) 
  #jboss-twiddle ${opts[@]} invoke "$JBOSS_LOGGING" setLoggerLevel $1 $2 
}

function jboss7-tailsrv() {
  jboss7-opts $@
  tail -f "$JBOSS_HOME/standalone/log/server.log"
}

function jboss7-visrv() {
  jboss7-opts $@
  vi "$JBOSS_HOME/standalone/log/server.log"
}

# ---------------------------------------------------------------------
#   Aliases
# ---------------------------------------------------------------------

function startjboss7() {
  jboss7-start $@
}

function stopjboss7() {
  jboss7-stop $@
}

function tailsrv7() {
  jboss7-tailsrv $@
}

function visrv7() {
  jboss7-visrv $@
}

