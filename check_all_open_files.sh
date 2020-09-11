#!/bin/bash
# 
# Inspired by: http://pissedoffadmins.com/nagios/nagios-tomcat-open-files-check.html
#
# Author: Gregor Binder
# Mail: office@wefixit.at
# https://github.com/wefixit-AT/nagios_check_all_open_files
# Adapted for BGHW by Johannes Starosta <j.starosta@bghw.de>

# Bash strict mode, to make debugging easier see http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

SUDO=sudo
LSOF=lsof

ERROR_CODE=-1
set +u
if [ -z "$1" ] || [ -z "$2" ] || [ "$2" -lt "$1" ] ; then
    echo "Usage: $0 warning critical"
    echo "  warning: int"
    echo "  critical: int and >= warning"
    echo " program: Optional String with name of program"
    echo "IMPORTANT: sudo must set without password asking to allow lsof"
    exit $ERROR_CODE
else
    WARNING=$1
    CRITICAL=$2
fi
set -u

function checkExitStatus {
    if [ "$1" -ne 0 ]; then
        echo "!!! command failure !!! $2"
        exit -1
    fi
}
if [ -z "$3" ];then
    LSOF=$("$SUDO" "$LSOF" | "$WC" -l)
else
    LSOF=$("$SUDO" "$LSOF" -p "$("$PGREP" -f "$3")" | "$WC" -l)
fi
if [ "$LSOF" -lt "$WARNING" ]; then
    echo "OK $LSOF files open|files=$LSOF;$WARNING;$CRITICAL;0"
    ERROR_CODE=0
else
    if [ "$LSOF" -ge "$WARNING" ] && [ "$LSOF" -le "$CRITICAL" ]; then
        echo "WARN $LSOF files open|files=$LSOF;$WARNING;$CRITICAL;0"
        ERROR_CODE=1
    elif [ "$LSOF" -ge "$CRITICAL" ]; then
        echo "CRIT $LSOF files open|files=$LSOF;$WARNING;$CRITICAL;0"
        ERROR_CODE=2
  fi
fi

exit $ERROR_CODE
