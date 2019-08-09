#!/bin/bash

# Sprawdzenie aktualnej wersji pliku hosts 
LOCAL_HOSTS_PATH="/etc/hosts"
MFS_HOSTS_PATH="/opt/software/Blueocean/Configs/docker_hosts/hosts"
LOCAL_HOSTS_MD5=$(md5sum $LOCAL_HOSTS_PATH|awk '{print $1}')
MFS_HOSTS_MD5=$(md5sum $MFS_HOSTS_PATH |awk '{print $1}')

if [ $LOCAL_HOSTS_MD5 != $MFS_HOSTS_MD5 ]; then
    echo "Plik hosts jest rozny od $MFS_HOSTS_PATH, konieczna aktualizacja na lokalnym hoscie"
    cp -a $MFS_HOSTS_PATH $LOCAL_HOSTS_PATH
    exit 1
else 
    echo "Plik hosts jest zgodny z $MFS_HOSTS_PATH"
    exit 0
fi
