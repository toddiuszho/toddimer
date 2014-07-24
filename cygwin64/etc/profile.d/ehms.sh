
source /usr/local/lib/imports.sh
lib_imports table fileutil
group_imports jboss twiddle

export URL_BUILDS="http://db4:11080/builds"
export DIR_XFER="/opt/xfer"
export DIR_UPDATES="/opt/updates"
export DIR_BUILDS="/var/www/builds"

export EHMS_CONTEXT_PATH="${EHMS_CONTEXT_PATH:-/ehms}"
export EHMS_EAR='ehms.ear'
export EHMS_HOME="${EHMS_HOME:-/opt/ehms}"
export EHMS_PROTOCOL="${EHMS_PROTOCOL:-http}"

export FLUX_JNI_PORT="${FLUX_JNI_PORT:-2099}"
export FLUX_SERVLET_PATH="${FLUX_SERVLET_PATH=/flux}"

# Availability Monitoring
MONITOR_CONTENT="${MONITOR_CONTENT:-Monitor}"
MONITOR_FILE="${MONITOR_FILE:-monitor.html}"
MONITOR_FLAG=${MONITOR_FLAG:-0}
MONITOR_RETRIES=10
MONITOR_SECONDS_BEFORE_RETRY=3

# -- Flux --

#
# Load Flux schema into a database.
#
# Options:
#   n - Optional. do not try to create schema
#       Defaults to trying to create schema
#   passthrough: mysql-create-schema
#   passthrough: mysql-load
#
function flux-setup-schema()
{
  local dbscript="$EHMS_HOME/flux-schema.sql"
  if ! [ -f "$dbscript" ]; then
    echo "Cannot find $dbscript. Check EHMS_HOME=$EHMS_HOME" >&2
    return 1
  fi
  
  declare -i _do_create=0
  local _file=""
  local db=""
  while getopts ":d:f:n" opt; do
    case "$opt" in
      d) db="$OPTARG";;
      n) _do_create=1;;
      f) _file="$OPTARG";;
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0
  
  if [[ $_do_create -eq 0 ]]; then
    mysql-create-schema -d "$db" -f "$_file" "flux-setup-schema"
  else
    echo "Skipping create of schema $db." >&2
  fi
  
  mysql-load -d "$db" -f "$_file" "$dbscript" "flux-setup-schema"
}

#
# Populate an existing Flux schema with initial Flux users.
#
# Options
#   d - schema name to load script into
#   f - defaults-file for permissions
#
function flux-setup-users()
{
  local dbscript="$EHMS_HOME/flux-users.sql"
  if ! [ -f "$dbscript" ]; then
    echo "Cannot find $dbscript. Check EHMS_HOME=$EHMS_HOME" >&2
    return 1
  fi
  
  mysql-load $@ "$dbscript" "flux-setup-users"
}

#
# Perform a cmdline Flux client action
#
# Options:
#   passthrough: jboss7-opts
#
# Arguments:
#   1 - Required. Description of action being taken
#   2 - Required. action being taken
#   3+ - Optional. Parameters to action
#
function flux-client()
{
  jboss7-opts $@
  shift $(( $? - 1 ))
  
  echo "$1 on node $JBOSS_CONF at $JBOSS_LISTEN ..." >&2
  shift 1
  
  # Can Flux be found?
  if ! [ -f "$EHMS_HOME/flux.jar" ]; then
    echo "Cannot find $EHMS_HOME/flux.jar. Check EHMS_HOME=$EHMS_HOME" >&2
    return 1
  fi
  
  # Can Xerces be found?
  if ! [ -f "$JBOSS_HOME/lib/endorsed/xercesImpl.jar" ]; then
    echo "Cannot find $JBOSS_HOME/lib/endorsed/xercesImpl.jar. Check JBOSS_HOME=$JBOSS_HOME" >&2
    return 1
  fi

  # Classpath wrangling
  local CP="$EHMS_HOME/flux.jar:$JBOSS_HOME/lib/endorsed/xercesImpl.jar"
  if [[ "Cygwin" = `uname -o` ]]; then
    CP=`cygpath --path -aw "$CP"`
  fi
  
  # Launch!
  java -cp "$CP" \
    flux.Main client -host "$JBOSS_LISTEN" \
                     -registryport $FLUX_JNI_PORT \
                     -username admin \
                     -encryptedpassword "6vQZjh4KhTw=" \
                     "$@"
}

function flux-setup()
{
  flux-setup-schema $@
  flux-setup-users $@
}

function flux-start()
{
  jboss7-opts $@
  echo "Starting Flux on node $JBOSS_CONF at $JBOSS_LISTEN ..." >&2
  curl --connect-timeout 10 --max-time 40 -D - --location -k $EHMS_PROTOCOL://$JBOSS_LISTEN:$JBOSS_WEB_PORT$EHMS_CONTEXT_PATH$FLUX_SERVLET_PATH
}

function flux-stop()
{
  jboss7-opts $@
  shift $(( $? - 1 ))
  flux-client opts[@] "Stopping Flux" stop $@
}

function flux-export()
{
  jboss7-opts $@
  shift $(( $? - 1 ))
  flux-client opts[@] "Exporting $1" "export" $@
}

function flux-expedite()
{
  jboss7-opts $@
  shift $(( $? - 1 ))
  flux-client opts[@] "Expediting $1" expedite $@
}

function startflux()
{
  flux-start "$@"
}

# -- EHMS --

_ehms_lbstats_colwidths=(12 6 9)
_ehms_lbstats_colformats=("%12s" "%'6d" "%'9d")

function _ehms-lbstats-table-line()
{
  table-line - "${_ehms_lbstats_colwidths[@]}"
}

function _ehms-lbstats-table-header()
{
  table-header _ehms_lbstats_colwidths Device Active Total
}

function _ehms-lbstats-table-row()
{
  table-row -H _ehms_lbstats_colformats "$@"
}

function _ehms-lbstats-table-footer()
{
  table-row _ehms_lbstats_colformats "$@"
}

function _ehms-lbstats-table-row-header()
{
  table-row-header ${_ehms_lbstats_colwidths[0]} $1
}

function _ehms-lbstats-debug()
{
  _ehms-lbstats-table-header
  _ehms-lbstats-table-line
  _ehms-lbstats-table-row-header web2
  _ehms-lbstats-table-row 50 500
  _ehms-lbstats-table-row-header somelongdev
  _ehms-lbstats-table-row 60 600
  _ehms-lbstats-table-line
  _ehms-lbstats-table-footer "2 of 2" 110 1100
}

function ehms-lbstat()
{
  local passfile="/opt/jboss/jboss7/remote-management-credentials"
  local password=`head -n 1 "$passfile"`
  local host="$1"
  local server="$1"
  declare -A passwords=()

  if [ "$host" != "${host/ /}" ]; then
    server=`echo "$host" | cut -d ' ' -f 1`
    host=`echo "$host" | cut -d ' ' -f 2`
  fi

  local passfileserver="${passfile}-${server}"
#  echo passfileserver
  if [ -e "${passfileserver}" ]; then
#    echo "Reading server specific credentials."
    password=`head -n 1 "${passfileserver}"`
  fi

  local mbean="jboss.web:type=Manager,path=/ehms,host=default-host"
  _ehms-lbstats-table-row-header "${server}"
  local results=$("$TWIDDLE_HOME/bin/widdle" -h "${host}" -p"${password}" -q get --noprefix "${mbean}" activeSessions sessionCounter 2>&1)
  echo "$results" | grep -P '[a-z]' 2>&1 > /dev/null
  if [ $? -ne 0 ]; then
    # strip off \r\n
    _ehms-lbstats-table-row `echo "$results" | grep --color=never -Po '\d+'`
  else
    #_ehms-lbstats-table-row -1 -1
    echo -e "-ERROR-\n$results"
  fi
}

#
# Print EHMS session stats for JBoss AS7.
# Reads space delimited file /etc/ehms-lbstats in format: FRIENDLYNAME HOSTNAME
# If FRIENDLYNAME is absent, HOSTNAME is used as both.
#
# Arguments:
#   1  - if "-", skip grabbing list from file
#   1+ - list of HOSTNAMEs to grab stats for
#
function ehms-lbstats()
{
  # Abort if no twiddle
  twiddle-verify
  if [ $? -ne 0 ]; then
    return 1
  fi

  # Setup
  local usefile=0
  local aliasonly=1
  local serverfile="/etc/ehms-lbstats"
  local summary="/tmp/ehms-lbstats-$$"
  declare -A aliases=()

  # If first arg is "-", skip file
  if [ "$1" = "-" ]; then
    usefile=1
    shift 1
  fi

  if [ "$1" = "-a" ]; then
    aliasonly=0
    shift 1
  fi
 
  # Header
  _ehms-lbstats-table-header
  _ehms-lbstats-table-line
  
  # If specified server file is not empty string and exists ...
  if [ $usefile -eq 0 ]; then
    if [ -n "$serverfile" ] && [ -e "$serverfile" ]; then
      # Is it really a file?
      if ! [ -f "$serverfile" ]; then
        echo "Specified server file [$serverfile] is not a file!" >&2
        return 10
      fi
    
      # Is it readable
      if ! [ -r "$serverfile" ]; then
        echo "Specified server file [$serverfile] is not readable!" >&2
        return 20;
      fi
    
      # Process
      while read line; do
        if [ -n "$line" ]; then
          if [ $aliasonly -eq 0 ]; then
            key=${line% *}
            val=${line#* }
            aliases+=([$key]=$val)
          else
            ehms-lbstat "$line" | tee -a "$summary"
          fi
        fi
      done < <(cat "$serverfile")
    fi
  fi

  # If passed in hosts ...
  if [ $# -gt 0 ]; then
    for server in "$@"; do
      lookup=${aliases[$server]}
      if [ -n "$lookup" ]; then
        ehms-lbstat "$server $lookup" | tee -a "$summary"
      else
        ehms-lbstat "$server" | tee -a "$summary"
      fi
    done
  fi

  # Summary
  _ehms-lbstats-table-line
  declare -a ends=(`awk 'BEGIN { tn=0; sn=0; as=0; ts=0; } { tn++; if (index($0, "failed") == 0) { gsub(/,/,"",$2); gsub(/,/,"",$3); as += $2; ts += $3; sn++; } } END { print sn " " tn " " as " " ts }' "$summary"`)
  if [ $? -eq 0 ]; then
    \rm -f "$summary"
    _ehms-lbstats-table-footer "${ends[0]} of ${ends[1]}" ${ends[2]} ${ends[3]}
  fi
  
  return 0
}

function ehms-start-wait()
{
  jboss7-opts $@
  
  twiddle-verify
  if [ $? -ne 0 ]; then
    return 1
  fi
  
  local mbean_deployment='jboss.as:deployment=ehms.ear'
  local mbean_server='jboss.as:management-root=server'
  local sleep_time=7

  # Change below to real file to troubleshoot
  local log=/dev/null
   
  # pound until listener active
  echo -n "Waiting for Listener ."
  while true; do
    if $($TWIDDLE_HOME/bin/widdle -q get --noprefix "$mbean_server" serverState 2>&1 >> $log); then
        echo ''
        printsuccess -b LISTENING
        break
    fi
    echo -n .
  done
  
  # pound until server started
  echo -n "Waiting for server complete start ."
  while true; do
    local started=`twiddle-get "$log" "$mbean_server" serverState`
    if [ "$started" = "running" ]; then
      echo ''
      printsuccess -b STARTED
      break
    else
      echo -n "$started" >> $log
    fi
    echo -n .
  done
  
  # pound until deployed or failed to do so
  echo -n "Waiting for $EHMS_EAR deployment ."
  declare -i deployed=1
  for i in `seq 1 20`; do
    local enabled=`twiddle-get "$log" "$mbean_deployment" enabled`
    local status=`twiddle-get "$log" "$mbean_deployment" status`
    
    if [ "$enabled" = "true" ] && [ "$status" = "OK" ]; then
      echo ""
      printsuccess -b DEPLOYED
      deployed=0
      break
    fi
    
    sleep ${sleep_time}
    echo -n .
  done
  
  # Couldn't find
  if [ $deployed -ne 0 ]; then
    printfailure DEPLOYMENT NOT FOUND
    return 10
  fi

  # Acquire Port
  local port=0
  for connector in $($TWIDDLE_HOME/bin/widdle -q query 'jboss.web:type=Connector,*'); do
    port=`echo $connector | grep -Po "(?<=port=)\d+"`
  done
  if [ "$port" = 0 ]; then
    printfailure 'PORT LOOKUP FAILURE'
    return 20
  fi
  
  # Hit servlet
  local testing="${EHMS_PROTOCOL}://${JBOSS_LISTEN}:${port}${EHMS_CONTEXT_PATH}/login.seam"
  echo "Testing URL: $testing"
  testurl "$testing"
  declare -i res=$?
  if [ $res -eq 0 ]; then
    printsuccess -b READY
  else
    printfailure "Not properly serving content"
  fi
}

#
# Copies EAR from ready-to-deploy to actually deployed
#
# Passthrough: jboss7-opts
#
function ehms-deploy()
{
  jboss7-opts $@

  echo "Deploying to \$JBOSS_CONF=$JBOSS_CONF ..." >&2

  local EAR=ehms.ear
  local SRC=/opt/updates
  local SINK="/opt/jboss/jboss7/standalone/deployments"
  local ug=jboss

  # Verify SRC
  if ! [ -d "$SRC" ]; then
    printfailure "Cannot find source directory: $SRC"
    return 1
  fi

  # Verify something to deploy
  if ! [ -f "$SRC/$EAR" ]; then
    echo "No EAR to deploy. Exiting." >&2
    return 0
  fi

  # Verify SINK
  if ! [ -d "$SINK" ]; then
    printfailure "Nowhere to deploy to. Directory does not exist: $SINK"
    return 1
  fi

  # Assure writability at SINK
  if ! [ -w "$SINK" ]; then
    sudo chown $ug:$ug "$SINK"
    chmod g+rwx "$SINK"
  fi

  # Assure r/w of previously deployed
  if [ -f "$SINK/$EAR" ] && ! [ -w "$SINK/$EAR" ]; then
    sudo chown $ug:$ug "$SINK/$EAR"
    chmod g+rw "$SINK/$EAR"
  fi

  # Assure r/w of that to deploy
  if ! [ -r "$SRC/$EAR" ] || ! [ -w "$SRC/$EAR" ]; then
    sudo chown $ug:$ug "$SRC/$EAR"
    chmod g+rw "$SRC/$EAR"
  fi

  # Warn if deploying older EAR
  if [ "$SRC/$EAR" -ot "$SINK/$EAR" ]; then
    printwarning "Deploying an OLDER EAR than what is already deployed."
  fi

  # Exec
  \cp -pf "$SRC/$EAR" "$SINK/$EAR"
  sudo chown $ug:$ug "$SINK/$EAR"
  if [ $? -eq 0 ]; then
    printsuccess -b DEPLOYED
    return 0
  else
    printfailure -b "NOT DEPLOYED"
    return 1
  fi

  return 0
}

#
# Manage copy of currently deployed EAR, backup of previously deployed EAR, and
# retrieve new EAR candidate. If new candidate is newer than current, or forced,
# remove previous EAR, demote current EAR to previous EAR, and promote new EAR
# to ready-to-deploy EAR.
#
# Options:
#   f - force deployment of new EAR even if deemed older/same than stored current EAR
#   l - prepare locally stored EAR instead of retrieving from published builds
#
function ehms-prepare()
{
  local EAR="ehms.ear"
  local BUILDS="http://db4:11080/builds"
  local XFER=/opt/xfer
  local UPDATES=/opt/updates
  declare -i rez=0 force=1 uselocal=1 modules=1 datasources=1 get_ear=0

  cd $UPDATES

  # Parse options
  while getopts "deEflm" opt; do
    case $opt in
      d ) datasources=0;;
      e ) get_ear=0;;
      E ) get_ear=1;;
      f ) force=0;;
      l ) uselocal=0;;
      m ) modules=0;;
      \?) echo "Unknown option!" >&2
          return 1 ;;
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0

  # Hardening old, just to be sure
  for file in $UPDATES/ehms* $UPDATES/*-module.zip; do
    if [ -f "$file" ]; then
      sudo chown jboss:jboss "$file"
      sudo chmod g+rw "$file"
    fi
  done

  if [ $modules -eq 0 ]; then
    # TODO figure out dynamic module discovery
    for module in viverae jsf-api jsf-impl mysql jboss-as-jpa; do
      wget -nH -O ${module}-module.zip $BUILDS/${module}-module.zip
    done
  fi

  if [ $datasources -eq 0 ]; then
    for ds in ehms-prod-ds.xml ehms-flux-ds.xml; do
      wget -nH -O $ds $BUILDS/$ds
    done
  fi

  # Harden new
  for file in $UPDATES/ehms* $UPDATES/*-module.zip; do
    if [ -f "$file" ]; then
      sudo chown jboss:jboss "$file"
      sudo chmod g+rw "$file"
    fi
  done

  # Remove any previous candidates for a new EAR
  if [ -f "$EAR.new" ]; then
    echo "Removing previous new EAR candidate." >&2
    \rm "$EAR.new"
  fi

  # Find/retrieve new EAR candidate
  if [ $uselocal -eq 0 ]; then
    # Try EAR.new, then just plain EAR
    if [ -f "$XFER/$EAR.new" ]; then
      echo "Moving $XFER/$EAR.new to use as new EAR candidate." >&2
      \mv $XFER/$EAR.new $EAR.new
      rez=$?
    elif [ -f "$XFER/$EAR" ]; then
      echo "Moving $XFER/$EAR to use as new EAR candidate." >&2
      \mv $XFER/$EAR $EAR.new
      rez=$?
    fi
  else
    echo "Downloading new EAR from published builds." >&2
    wget -nH -O "$EAR.new" "$BUILDS/$EAR"
    rez=$?
  fi

  if [ $rez ]; then
    # Harden candidate
    sudo chown jboss:jboss "$EAR.new"
    sudo chmod 660 "$EAR.new"

    # Compare
    if [ $force -eq 0 ] || ([ -e "$EAR" ] && [ "$EAR.new" -nt "$EAR" ]); then
      # Report forcing
      if [ $force -eq 0 ]; then
        echo "Forcing newly downloaded EAR to now be read-to-deploy EAR." >&2
      fi
      # Remove previous EAR
      if [ -e "$EAR.previous" ]; then
        echo "Removing backed up EAR." >&2
        \rm -f "$EAR.previous"
      fi
      # Demote current EAR to backup EAR
      if [ -e "$EAR" ]; then
        echo "Previously ready-to-deploy EAR now backed up EAR." >&2
        \mv "$EAR" "$EAR.previous"
      fi
      # Promote new EAR to current EAR
      \mv "$EAR.new" "$EAR"
      [ $? -eq 0 ] && printsuccess -b DONE "Newly downloaded EAR now ready-to-deploy EAR."
    # Promote new EAR to current EAR, report lack of current EAR
    elif ! [ -e "$EAR" ]; then
      echo "No previously read-to-deploy EAR existed." >&2
      \mv "$EAR.new" "$EAR"
      [ $? -eq 0 ] && printsuccess -b DONE "Newly downloaded EAR now ready-to-deploy EAR."
    else
      printwarning "Newly downloaded EAR is not newer! Abandoning."
    fi
  else
    printfailure  "Failed to find/retrieve new EAR!"
  fi

  \ls -Fla --color /opt/updates
}

#
# Publish pushed artifacts, wrangling the previously published artifacts.
#
# Options:
#   f -- force publish even if older
#
function ehms-publish()
{
  local pub=/var/www/builds
  local pushed=/opt/xfer
  local ug=apache
  local force=1

  # OPtions
  while getopts "f" opt; do
    case "$opt" in
      f) force=0;;
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0

  # Harden
  for file in $pub/ehms* $pub/*-module.zip; do
    if [ -f "$file" ]; then
      sudo chown $ug:$ug "$file"
      sudo chmod ug+rw "$file"
    fi
  done
  for file in $pushed/ehms* $pushed/*-module.zip; do
    if [ -f "$file" ]; then
      sudo chown $ug:$ug "$file"
      sudo chmod ug+rw "$file"
    fi
  done

  # Exec if newer and exists
  if [ $force -eq 0 ] || [ $pushed/ehms.ear -nt $pub/ehms.ear ]; then
    if [ -f $pub/ehms.ear ]; then
      echo 'Backing up previous deployment.' >&2
      \rm -f $pub/previous/*
      \mv $pub/ehms* $pub/previous/
      \mv $pub/*-module.zip $pub/previous/
    fi
    \mv $pushed/ehms* $pushed/*-module.zip $pub/
    [ $? -eq 0 ] && printsuccess -b DONE 'Updated.'
    \ls -Fla --color $pub
    return 0
  fi

  printwarning 'Nothing to do. Exiting.'
  \ls -Fla --color $pushed

  return 0
}

function ehms-monitor-usage()
{
  echo "ehms-monitor: change or show healthcheck monitors" >&2
  echo "" >&2
  echo "Options:" >&2
  echo "  -c STATUS   Change monitor status to STATUS" >&2
  echo "  -h          Help" >&2
  echo "  -s          Show all current monitors" >&2
  echo "" >&2
  echo "Statuses:" >&2
  echo "  ACTIVE  - Accept all new connections. Process current requests." >&2
  echo "  DISABLE - Only accept persistent new connections. Process current requests." >&2
}

function ehms-monitor()
{
  # Setup
  local m_status=ACTIVE
  declare -A m_statuses=([ACTIVE]=OK [DISABLE]=DOWN)
  declare -a m_parents=("$JBOSS_HOME/welcome-content" "/var/www/html")
  declare -a m_files=("monitor.html" "keepalive.htm")
  declare -a m_paths=()

  # Combine parents + files = paths
  for m_parent in "${m_parents[@]}"; do
    for m_file in "${m_files[@]}"; do
      m_paths+=("$m_parent/$m_file")
    done
  done

  # Parse options
  while getopts "c:hs" opt; do
    case "$opt" in
      c) m_status="$OPTARG";;
      h) ehms-monitor-usage; OPTIND=0; return 0;;
      s) for m_path in "${m_paths[@]}"; do
           echo "$m_path"
           echo "------------"
           if ! [ -f "$m_path" ]; then
             echo "[ERROR] Path $m_path does not exist!"
           else
             cat "${m_path}"
           fi
           echo ""
         done
         OPTIND=0
         return 0;;
    esac
  done
  shift $(( OPTIND - 1 ))
  OPTIND=0

  # Validate status
  declare -i m_valid_status=1
  for m_check in "${!m_statuses[@]}"; do
    if [ "$m_check" = "$m_status" ]; then
      m_valid_status=0
    fi
  done
  if [ $m_valid_status -ne 0 ]; then
    printfailure "Invalid status: $m_status"
    ehms-monitor-usage
    return 1
  else
    echo "Changing status to $m_status."
  fi

  # Validate parents
  for m_parent in "${m_parents[@]}"; do
    if ! [ -e "$m_parent" ]; then
      printfailure "Parent $m_parent does not exist!"
      return 1
    fi
    if ! [ -d "$m_parent" ]; then
      printfailure "Parent $m_parent is not a directory!"
      return 1
    fi
    if ! [ -w "$m_parent" ]; then
      printfailure "Parent $m_parent is not writable!"
      return 1
    fi
  done

  # Emit
  for m_path in "${m_paths[@]}"; do
cat > "$m_path" <<EOH
<html>
<head>
  <title>Health Monitor Check</title>
</head>
<body>
  <h1>${m_status} - ${m_statuses[$m_status]}</h1>
</body>
</html>
EOH

    # Harden
    m_parent=`dirname "$m_path"`
    m_owner=`stat --printf="%U:%G" "$m_parent"`
    sudo chown "${m_owner}" "$m_path"
    sudo chmod 664 "$m_path"
  done

  printsuccess -b DONE
  return 0
}

function deploy-ear()
{
  ehms-deploy "$@"
}

function publish-ear()
{
  ehms-publish "$@"
}

function prepare-ear()
{
  ehms-prepare "$@"
}

function lbstats()
{
  ehms-lbstats "$@"
}
