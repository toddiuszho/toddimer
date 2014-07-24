
#
# java.sh: java aliases and functions
#

export JAVA_HOME=${JAVA_HOME:-/usr/java/default}
if [ "Cygwin" = `uname -o` ]; then
    JAVA_HOME=`cygpath -au "$JAVA_HOME"`
fi

pathadd -f -s "$JAVA_HOME/bin" "Java binaries"
pathadd -f -s "/bin" "Heimdal"

