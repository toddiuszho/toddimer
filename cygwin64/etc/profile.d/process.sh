#
# Process function library
#

#
# Super Process GREP
#
# Arguments
#   1 -- process name to GREP
#
function spgrep()
{
    ps aux | grep "$1" | grep -v "grep" | xargs -I{} echo -e "{}\n"
}

function net()
{
  if [ -n "$1" ] && [ -n "$2" ]; then
    if [ "$1" = "restart" ]; then
      echo "Restarting $2 ..."
      command net start | grep -P "$2$" > /dev/null
      if [ $? -eq 0 ]; then
        command net stop "$2" && command net start "$2"
      else
        command net start "$2"
      fi
    else 
      if [ "$1" = "status" ]; then
        command net start | grep -P "$2$" > /dev/null
        if [ $? -eq 0 ]; then
          echo "$2 is started."
        else
          echo "$2 is stopped."
        fi
      else
        command net "$@"
      fi
    fi
  else
    command net "$@"
  fi
}

