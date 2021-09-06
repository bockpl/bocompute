#!/bin/sh
#/usr/sbin/nslcd -d
#/usr/sbin/nslcd -d 
/usr/bin/kill $(cat /var/run/nslcd/nslcd.pid)

