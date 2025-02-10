#!/bin/bash

if [ ! -e "/etc/ceph/ceph.conf" ]; then
  cp /etc/ceph/ceph.conf.template /etc/ceph/ceph.conf
  sed -i -e 's/@@FSID@@/'"$FSID"'/' /etc/ceph/ceph.conf
  mon_ip_address=$(cat /var/lib/ceph/shared-data/mon-master.ip-address)
  sed -i -e 's/@@MON_IP_ADDRESS@@/'"$mon_ip_address"'/g' /etc/ceph/ceph.conf

  mkdir -p /var/lib/ceph/radosgw/ceph-admin
  cp /var/lib/ceph/shared-data/ceph.client.admin.keyring /var/lib/ceph/radosgw/ceph-admin/keyring
  chown -R ceph:ceph /var/lib/ceph/radosgw/ceph-admin
  mkdir /var/lib/ceph/radosgw/ceph-rgw
  cp /var/lib/ceph/shared-data/rgw-keyring /var/lib/ceph/radosgw/ceph-rgw/keyring
  chown -R ceph:ceph /var/lib/ceph/radosgw/ceph-rgw
  chown -R ceph:ceph /var/run/ceph
fi

/usr/local/bin/start-ceph-rgw.sh
