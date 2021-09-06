#!/bin/sh
#/usr/sbin/nslcd -d 
/usr/bin/kill $(cat /var/run/slurmd/slurmd.pid) 
/usr/bin/rm /var/run/slurmd/slurmd.pid 

