#!/bin/bash

if [ ! -e "/etc/ceph/ceph.conf" ]; then
  cp /etc/ceph/ceph.conf.template /etc/ceph/ceph.conf
  sed -i -e 's/@@FSID@@/'"$FSID"'/' /etc/ceph/ceph.conf
  mon_ip_address=$(cat /var/lib/ceph/shared-data/mon-master.ip-address)
  sed -i -e 's/@@MON_IP_ADDRESS@@/'"$mon_ip_address"'/g' /etc/ceph/ceph.conf

  i=1
  while [ "$i" -lt "60" ]; do
    if [ -e "/var/lib/ceph/shared-data/mgr-keyring" ]; then
      sleep 1
      i=60
    else
      sleep 1
      i=$(($i+1))
    fi
  done

  mkdir /var/lib/ceph/mgr/ceph-mgr-master
  cp /var/lib/ceph/shared-data/mgr-keyring /var/lib/ceph/mgr/ceph-mgr-master/keyring
  cp /var/lib/ceph/shared-data/ceph.client.admin.keyring /etc/ceph/ceph.client.admin.keyring
  chown -R ceph:ceph /var/lib/ceph/mgr/ceph-mgr-master
fi

/usr/local/bin/start-ceph-mgr.sh
