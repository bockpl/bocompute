#!/bin/bash
/opt/pbis/sbin/lwsmd --syslog& echo $! > /var/run/pbis.pid && \
sleep 5 && \
domainjoin-cli join --disable ssh adm.p.lodz.pl blueocean $(cat /opt/software/Blueocean/Configs/bo_password)
