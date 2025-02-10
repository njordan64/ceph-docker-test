#!/bin/bash

if [ ! -e "/etc/ceph/ceph.conf" ]; then
  cp /etc/ceph/ceph.conf.template /etc/ceph/ceph.conf
  sed -i -e 's/@@FSID@@/'"$FSID"'/' /etc/ceph/ceph.conf
  mon_ip_address=$(cat /var/lib/ceph/shared-data/mon-master.ip-address)
  sed -i -e 's/@@MON_IP_ADDRESS@@/'"$mon_ip_address"'/g' /etc/ceph/ceph.conf

  mkdir -p /var/lib/ceph/mds/ceph-mds
  cp /var/lib/ceph/shared-data/mds-keyring /var/lib/ceph/mds/ceph-mds/keyring
  chown -R ceph:ceph /var/lib/ceph/mds/ceph-mds
  chown -R ceph:ceph /var/run/ceph
fi

/usr/local/bin/start-ceph-mds.sh
