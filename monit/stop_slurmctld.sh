#!/bin/sh
#/usr/sbin/nslcd -d 
/usr/bin/kill $(cat /var/run/slurmd/slurmctld.pid) 
/usr/bin/rm -fR /var/run/slurmd/slurmctld.pid 

