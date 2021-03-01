#!/bin/bash

yum list installed nfs-utils > /dev/null 
error=$?

if [[ $error -ne 0 ]]
    then
        yum install nfs-utils
fi

if [[ ! -d /mnt/nfs  ]]
    then
        mkdir  /mnt/nfs
fi


mountpoints=$(showmount -e 192.168.50.10)
error=$?

fstabtest=$(grep '192.168.50.10:/nfs_share' /etc/fstab > /dev/null 2>&1)
errorfstab=$?

if [[ $error -ne 0 ]]
    
    then
        echo -e "\e[31mПроблемы с сетевым диском NFS !\e[0m"
        exit 123
    elif [[ $errorfstab -ne 0 ]]
    
           then
                echo -e "\e[32m$mountpoints\e[0m"
                cp /vagrant/mnt-nfs.mount  /etc/systemd/system/
                #cp /vagrant/mnt-nfs.automount /etc/systemd/system/
                systemctl daemon-reload
               # systemctl enable mnt-nfs.automount
                systemctl enable --now mnt-nfs.mount
                echo "192.168.50.10:/nfs_share  /mnt/nfs    nfs     rw,noatime,noauto,x-systemd.automount,noexec,nosuid,udp,vers=3  0 0" >> /etc/fstab
                cd /mnt/nfs/
                sleep 20
                cd /mnt/nfs/uploads
                echo "test" >> /mnt/nfs/uploads/test
         
fi





