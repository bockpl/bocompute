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

# Start SSH process:
cp /opt/software/Blueocean/Configs/ssh/id_rsa /root/.ssh/
cp /opt/software/Blueocean/Configs/ssh/authorized_keys /root/.ssh/
chmod 700 /root/.ssh
chmod 600 /root/.ssh/id_rsa
chmod 600 /root/.ssh/authorized_keys
/usr/sbin/sshd -D &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start PBIS lwsmd process: $status"
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
sleep 5; domainjoin-cli join --disable ssh adm.p.lodz.pl blueocean $(cat /opt/software/Blueocean/Configs/bo_password)

# Start SOGE process
sleep 5; source /etc/profile.d/sge.sh; /etc/init.d/sgeexecd.blueocean-v15 start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start SOGE sge_execd process: $status"
  exit $status
fi

while sleep 15; do

  # Sprwdzenie aktualnej wersji pliku hosts 
  LOCAL_HOSTS_PATH="/etc/hosts"
  MFS_HOSTS_PATH="/opt/software/Blueocean/Configs/docker_hosts/hosts"
  LOCAL_HOSTS_MD5=$(md5sum $LOCAL_HOSTS_PATH|awk '{print $1}')
  MFS_HOSTS_MD5=$(md5sum $MFS_HOSTS_PATH |awk '{print $1}')

  if [ $LOCAL_HOSTS_MD5 != $MFS_HOSTS_MD5 ]; then
      echo -n "Plik hosts sa rozne, konieczna aktualizacja na lokalnym hoscie..."
      cp -a $MFS_HOSTS_PATH $LOCAL_HOSTS_PATH && echo "Poprawione!"
  fi

  ps aux |grep lwsmd |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep sge_execd |grep -q -v grep
  PROCESS_2_STATUS=$?
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi

done
