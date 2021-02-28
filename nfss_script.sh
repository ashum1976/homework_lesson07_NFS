#!/bin/bash

yum list installed nfs-utils
error=$?

if [[ $error ne 0 ]]
    then
        yum install nfs-utils
fi

mkdir -p /nfs_share/uploads
chown vagrant /nfs_share/uploads
echo "/nfs_share               192.168.50.11(ro,sync,root_squash,no_subtree_check)" > /etc/exports
echo "/nfs_share/uploads               192.168.50.11(rw,sync,root_squash,no_subtree_check)" >> /etc/exports

firewall-cmd --state > /dev/null  2>&1
error=$?

if [[ $error ne 0 ]]
    then
        systemctl enable --now firewalld
        firewall-cmd --permanent --zone=public --add-service=nfs
        firewall-cmd --permanent --zone=public --add-service=mountd
        firewall-cmd --permanent --zone=public --add-service=rpc-bind
        firewall-cmd --reload
    else 
        firewall-cmd --permanent --zone=public --add-service=nfs
        firewall-cmd --permanent --zone=public --add-service=mountd
        firewall-cmd --permanent --zone=public --add-service=rpc-bind
        firewall-cmd --reload   
fi

systemctl restart nfs-server rpcbind
