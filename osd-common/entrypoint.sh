#!/bin/bash

if [ ! -e "/etc/ceph/ceph.conf" ]; then
  cp /etc/ceph/ceph.conf.template /etc/ceph/ceph.conf
  sed -i -e 's/@@FSID@@/'"$FSID"'/' /etc/ceph/ceph.conf
  mon_ip_address=$(cat /var/lib/ceph/shared-data/mon-master.ip-address)
  sed -i -e 's/@@MON_IP_ADDRESS@@/'"$mon_ip_address"'/g' /etc/ceph/ceph.conf

  cp /var/lib/ceph/shared-data/bootstrap-osd-ceph.keyring /var/lib/ceph/bootstrap-osd/ceph.keyring

  UUID=$(uuidgen)
  echo ">>> $UUID"
  OSD_SECRET=$(ceph-authtool --gen-print-key)
  ID=$(echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | \
   ceph osd new $UUID -i - \
   -n client.bootstrap-osd -k /var/lib/ceph/bootstrap-osd/ceph.keyring)
  
  mkdir /var/lib/ceph/osd/ceph-$ID
  mkfs.xfs -f $OSD_DEV
  mount $OSD_DEV /var/lib/ceph/osd/ceph-$ID

  echo "Test 1"
  ceph-authtool --create-keyring /var/lib/ceph/osd/ceph-$ID/keyring \
    --name osd.$ID --add-key $OSD_SECRET

  echo "Test 2"
  ceph-osd -i $ID --mkfs --osd-uuid $UUID

  chown -R ceph:ceph /var/lib/ceph/osd/ceph-$ID
else
  mount $OSD_DEV /var/lib/ceph/osd/ceph-$ID
  ID=$(ls -1 /var/lib/ceph/osd | head -1 | sed -e 's/^ceph-//')
fi

/usr/local/bin/start-ceph-osd.sh $ID
