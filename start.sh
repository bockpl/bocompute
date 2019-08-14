#!/bin/bash
#mfsmount -S /blueocean/opt /opt && \
#mfsmount -S /blueocean/home /home && \
#mount -o bind /usr/local/pbis /opt/pbis && \
#/opt/pbis/sbin/lwsmd --syslog& echo $! > /run/lwsmd.pid) && \
#source /etc/profile.d/sge.sh; /etc/init.d/sgeexecd.blueocean-v15 start
#/opt/pbis/sbin/lwsmd --syslog
#sleep infinity

mfsmount -H mfsmaster.dev.p.lodz.pl -S /blueocean/opt /opt && \
mfsmount -H mfsmaster.dev.p.lodz.pl -S /blueocean/home /home && \
mount -o bind /usr/local/pbis /opt/pbis
status=$?
if [ $status -ne 0 ]; then
  echo "Faile in mount sequence: $status"
  exit $status
fi

# Ustawienie strefy czasowej
if ! [[ -z "$TIME_ZONE" ]]; then
  ln -sf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime
fi

# Jednokrotna aktualizacja liku hosts przy starcie, pozniej wywolywane systematycznie przez monit-a
/etc/monit.d/start_sync_hosts.sh

MONIT_OPT=-I
if ! [[-z "$DEBUG" ]]; then
  MONIT_OPT="$MONIT_OPT -vvv"  
fi
monit $MONIT_OPT
