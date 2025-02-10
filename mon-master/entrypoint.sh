#!/bin/bash

post_setup() {
    sleep 2
    ceph mon enable-msgr2
    ceph auth get-or-create mgr.mgr-master mon 'allow profile mgr' osd 'allow *' mds 'allow *' > /var/lib/ceph/shared-data/mgr-keyring
    ceph-authtool --create-keyring /var/lib/ceph/shared-data/mds-keyring --gen-key -n mds.mds
    ceph auth add mds.mds osd "allow rwx" mds "allow *" mon "allow profile mds" -i /var/lib/ceph/shared-data/mds-keyring
    ceph auth get-or-create client.$(hostname -s) mon 'allow rw' osd 'allow rwx' > /var/lib/ceph/shared-data/rgw-keyring
}

if [ ! -e "/etc/ceph/ceph.conf" ]
then
  cp /etc/ceph/ceph.conf.template /etc/ceph/ceph.conf

  sed -i -e 's/@@FSID@@/'"$FSID"'/' /etc/ceph/ceph.conf

  ip_address=$(awk '/32 host/ { print f } {f=$2}' <<< "$(</proc/net/fib_trie)" | grep -v '127.0.0.1' | head -1)
  sed -i -e 's/@@IP_ADDRESS@@/'"${ip_address}"'/g' /etc/ceph/ceph.conf

  escaped_ip_address=$(echo "$ip_address" | sed -e 's/\./\\./g')
  network=$(sed -e '/ '"${escaped_ip_address}"'$/,$d' /proc/net/fib_trie | grep '^     +--' | tail -1 | awk '{ print $2 }')
  escaped_network=$(echo "$network" | sed -e 's/\./\\./g')
  sed -i -e 's#@@NETWORK@@#'"${escaped_network}"'#' /etc/ceph/ceph.conf

  ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
  ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
  ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'
  ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
  ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
  chown ceph:ceph /tmp/ceph.mon.keyring

  monmaptool --create --add "mon-master" "$ip_address" --fsid "$FSID" /tmp/monmap

  chown ceph:ceph /var/lib/ceph/mon/ceph-mon-master

  sudo -u ceph ceph-mon --mkfs -i mon-master --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

  echo "$ip_address" > /var/lib/ceph/shared-data/mon-master.ip-address
  cp /etc/ceph/ceph.client.admin.keyring /var/lib/ceph/shared-data/ceph.client.admin.keyring
  cp /var/lib/ceph/bootstrap-osd/ceph.keyring /var/lib/ceph/shared-data/bootstrap-osd-ceph.keyring
  post_setup &
fi

/usr/local/bin/start-ceph-mon.sh
