#
# Networking Library
#

# 
# Get server name without machine ID or domain name
#
# Arguments:
#   1 - (Optional) name of server to strip machine ID and domain from.
#       Defaults to $HOSTNAME.
#
function servername() 
{
  host=${1:-$HOSTNAME}
  domainless=${host%%.*}
  deviceless=${domainless##[0-9][0-9][0-9][0-9][0-9][0-9]-}
  echo $deviceless
}

# Function alias for servername
function machinename()
{
  servername
}

#
# Test if a URL is good or bad, returning error status
#
# Arguments:
#   1 - Required. URL to test.
#
function testurl()
{
  curl --insecure --location --silent --fail --connect-timeout 60 --stderr - --output /dev/null "$1"
  return $?
}

# Export to env
export MACHINENAME=`servername`

