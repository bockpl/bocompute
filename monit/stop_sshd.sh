#!/bin/sh
/usr/bin/kill $(cat /var/run/sshd.pid)
