#!/bin/sh
#/usr/sbin/nslcd -d
/usr/bin/kill $(cat /var/run/munge/munged.pid) 
/usr/bin/rm -fR /var/run/munge/munge.socket.2 /var/run/munge/munge.socket.2.lock /var/run/munge/munged.pid  

