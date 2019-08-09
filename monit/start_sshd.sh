#!/bin/sh
cp /opt/software/Blueocean/Configs/ssh/id_rsa /root/.ssh/ && \
cp /opt/software/Blueocean/Configs/ssh/authorized_keys /root/.ssh/ && \
chmod 700 /root/.ssh && \
chmod 600 /root/.ssh/id_rsa && \
chmod 600 /root/.ssh/authorized_keys && \
/usr/sbin/sshd
