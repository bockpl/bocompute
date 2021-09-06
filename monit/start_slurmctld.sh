#!/bin/sh
#/usr/sbin/nslcd -d
#echo "---> Starting the Slurm Controller Daemon (slurmctld) ..."
gosu slurm /usr/sbin/slurmctld -vvv

