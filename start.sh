#!/bin/bash

# Ustawienie strefy czasowej
if ! [[ -z "$TIME_ZONE" ]]; then
  ln -sf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime
fi

# Jednokrotna aktualizacja liku hosts przy starcie, pozniej wywolywane systematycznie przez monit-a
/etc/monit.d/start_sync_hosts.sh

MONIT_OPT=-I
if ! [[ -z "$DEBUG" ]]; then
  MONIT_OPT="$MONIT_OPT -vvv"  
fi
monit $MONIT_OPT
