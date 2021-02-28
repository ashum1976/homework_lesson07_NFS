#!/bin/bash

yum list installed nfs-utils
error=$?

if [[ $error ne 0 ]]
    then
        yum install nfs-utils
fi

mountpoints=$(showmount -e 192.168.50.10)
error=$?

if [[ $error ne 0 ]]
    then
        echo -e "\e[31mПроблемы с сетевым диском NFS !\e[0m"
    else 
        echo -e "\e[32m$mountpoints\e[0m"
        echo "192.168.50.10:/nfs_share  /mnt    nfs     rw,noatime,noauto,x-systemd.automount,noexec,nosuid,udp,vers=3  0 0" >> /tec/fstab
        echo "test" >> /mnt/uploads/test
fi




