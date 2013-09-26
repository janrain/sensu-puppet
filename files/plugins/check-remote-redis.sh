#!/bin/bash
#
# Ping remote redis with netcat
#

while getopts 'h:p:help' OPT; do
    case $OPT in
  h) HOST=$OPTARG;;
  p) PORT=$OPTARG;;
  help) help="yes";;
  *) help="yes";;
    esac
done

# usage
HELP="
    usage: $0 [ -h value -p value -help ]

        -h --> host
        -p --> port
        -help --> print this help screen
"
if [ "$hlp" = "yes" ]; then
  echo "$HELP"
  exit 0
fi

(echo -en "PING\r\n"; sleep 1) | nc $HOST $PORT | grep -q PONG
RESULT=$?
case $RESULT in
  [0]) echo "OK"
    exit 0;;
  [1]) echo "CRITICAL"
    exit 2 ;;
  *)
    exit 2 ;;
esac
