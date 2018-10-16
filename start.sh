#!/bin/bash
#mfsmount -S /blueocean/opt /opt && \
#mfsmount -S /blueocean/home /home && \
#mount -o bind /usr/local/pbis /opt/pbis && \
#/opt/pbis/sbin/lwsmd --syslog& echo $! > /run/lwsmd.pid) && \
#source /etc/profile.d/sge.sh; /etc/init.d/sgeexecd.blueocean-v15 start
#/opt/pbis/sbin/lwsmd --syslog
#sleep infinity

mfsmount -S /blueocean/opt /opt && \
mfsmount -S /blueocean/home /home && \
mount -o bind /usr/local/pbis /opt/pbis
status=$?
if [ $status -ne 0 ]; then
  echo "Faile in mount sequence: $status"
  exit $status
fi

# Start PBIS process
(/opt/pbis/sbin/lwsmd --syslog& echo $! > /run/lwsmd.pid)
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start PBIS lwsmd process: $status"
  exit $status
fi

# Podlaczenie do domeny:
sleep 1; domainjoin-cli join --disable ssh adm.p.lodz.pl blueocean $(cat /opt/software/Blueocean/Configs/bo_password)

# Start SOGE process
source /etc/profile.d/sge.sh; /etc/init.d/sgeexecd.blueocean-v15 start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start SOGE sge_execd process: $status"
  exit $status
fi

while sleep 15; do
  ps aux |grep lwsmd |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep sge_execd |grep -q -v grep
  PROCESS_2_STATUS=$?
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done
