# Exit if not interactive
[[ "$-" != *i* ]] && return

# Shell Options
#
# Make bash append rather than overwrite the history on disk
shopt -s histappend
#
# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
shopt -s cdspell

# Completion options
#
# Define to avoid stripping description in --option=description of './configure --help'
COMP_CONFIGURE_HINTS=1
#
# Define to avoid flattening internal contents of tar files
COMP_TAR_INTERNAL_PATHS=1
#
# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
[[ -f /etc/bash_completion ]] && . /etc/bash_completion

#
# Aliases
#
# Some people use a different file for aliases
if [ -f "${HOME}/.bash_aliases" ]; then
  source "${HOME}/.bash_aliases"
fi

alias cgrep='grep --color'                     # show differences in colour
alias rum='rumm'
alias pythin='python'
alias copy='cp'


#
# Umask
#
# /etc/profile sets 022, removing write perms to group + others.
# Set a more restrictive umask: i.e. no exec perms for others:
# umask 027
# Paranoid: neither group nor others have any perms:
# umask 077
umask 003


#
# Functions
#
# Some people use a different file for functions
if [ -f "${HOME}/.bash_functions" ]; then
  source "${HOME}/.bash_functions"
fi

settitle () 
{ 
  echo -ne "\e]2;$@\a\e]1;$@\a"; 
}

find-in-files()
{
  declare -i num_args=2
  local usage="Usage: findinfiles ROOTDIRPATH PATTERN"

  if [ ${#@} != $num_args ]; then
    echo "$usage" >&2
    return 1
  fi

  find "$1" -type f -print0 | xargs -0 grep -H "$2"
}

param-prepare()
{
    echo "-----------"
    echo "  $1"
    echo "-----------"
    ssh -t "$1" '. /etc/profile; ehms-prepare;'
}

web-prepare()
{
  for i in web{1..5} wprod2{0..2} db3 db4 wdemo01; do
    param-prepare "web$i"
  done
}

lbstats()
{
  local host="web1"
  while getopts "h:" opt; do
    case "$opt" in
      h) host="$OPTARG";;
    esac
  done
  shift $(( $OPTIND - 1 ))
  OPTIND=0

  if [ -z "$host" ]; then
    host="web1"
  fi

  ssh -t "$host" "source /etc/profile; ehms-lbstats $@"
}


# Customization
# -------------


# Perforce
export P4USER=ttrimmer
export P4CLIENT=TTRIMMER002
export P4EDITOR='C:\cygwin64\bin\vim.exe'


# Normalization
alias vi='/usr/bin/vim'
export userprofile=`cygpath -au "$USERPROFILE"`


# Terminal
if [[ $TERM == xterm* ]]; then
  title='Zydeco'
  PS1+="\[\e]0;$title\007\]"
fi
eval `dircolors -b /etc/DIR_COLORS`


# Networking
alias home-james='toggle-proxy off; closesesame'
alias work-work='toggle-proxy on; opensesame'
export adapter="Wireless Network Connection"
alias illithid="ipconfig /release '$adapter'; ipconfig /renew '$adapter'"
alias juxtapose="net view '\\\\JUXTAPOSE'"
alias cb-r='net restart "Computer Browser"'
alias cb-p='net stop "Computer Browser"'
alias cb-t='net start "Computer Browser"'
alias hailmary='cb-r; illithid; juxtapose'
alias ifconfig='ipconfig'


# JBoss
export TWIDDLE_HOME=/opt/twiddle


# Rackspace
. /etc/group.d/adm/raxmon.sh


# Ruby
PATH=$HOME/.rvm/bin:$PATH # Add RVM to PATH for scripting


# XML
alias saxon="~/depot/enterprise/commons/xml/saxon.sh"


# Tunneling
_tunnel-up() {
  nohup tunnel -u ttrimmer -h svc1 -i svc1 -b TTRIMMER002 -l $2 -r $2 -t $1 &
}

_tunnel-down() {
  tunnel -t $1 -D
}

function kibana-tunnel-up() {
  _tunnel-up kibana 9200
}

function kibana-tunnel-down() {
  _tunnel-down kibana
}

