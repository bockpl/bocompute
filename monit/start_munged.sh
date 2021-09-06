#!/bin/sh
#/usr/sbin/nslcd -d
#echo "---> Starting the MUNGE Authentication service (munged) ..."
gosu munge /usr/sbin/munged 

