#!/bin/sh
#--------
# Check Socomec load status script for Icinga2
# Require: net-snmp-utils, bc
# v.20160524 by mmarodin
#
# https://github.com/mmarodin/icinga2-plugins
#

  while getopts ":V:H:C:w:c:h" optname ; do
    case "$optname" in
      "V")
        VERS=$OPTARG
        ;;
      "H")
        HOST=$OPTARG
        ;;
      "C")
        COMM=$OPTARG
        ;;
      "c")
        CRIT=$OPTARG
        ;;
      "w")
        WARN=$OPTARG
        ;;
      "h")
        echo "Useage: check_socomec_load.sh -H hostname -V version -C community -w warn -c crit"
        exit 2
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 2
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 2
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        exit 1
        ;;
    esac
  done

  [ -z $VERS ] && echo "Please specify SNMP version!" && exit 2
  [ -z $HOST ] && echo "Please specify hostname!" && exit 2
  [ -z $COMM ] && echo "Please specify SNMP community!" && exit 2
  [ -z $WARN ] && WARN=80
  [ -z $CRIT ] && CRIT=90

LOAD=`snmpwalk -v$VERS -c $COMM $HOST 1.3.6.1.4.1.4555.1.1.1.1.4.4.1.4.1 | grep -v "No Such Object" | awk '{print $4}'`

  [ ! "$LOAD" ] && echo "Execution problem, probably hostname did not respond!" && exit 2

  if [ $LOAD -ge $CRIT ] ; then
    echo -n "CRITICAL"
    EXIT=2
  elif [ $LOAD -ge $WARN ] ; then
    echo -n "WARNING"
    EXIT=1
  else
    echo -n "OK"
    EXIT=0
  fi
echo ": Load $LOAD% | 'load'=$LOAD%;$WARN;$CRIT;0"
exit $EXIT
