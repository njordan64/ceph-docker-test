#!/bin/bash

delete_volumes=0
if [ "$#" -eq "1" ]; then
  OSD_VOLUME_DIR="$1"
else
  if [ "$1" == "--delete-volumes" ]; then
    delete_volumes=1
  fi
  OSD_VOLUME_DIR="$2"
fi

fsid=$(uuidgen)
sed -i -e 's/^FSID=.*/FSID='"$fsid"'/' .env

rm -f mon-master/conf/ceph.conf
rm -f mon-master/conf/ceph.client.admin.keyring
rm -rf mon-master/ceph-mon-master/*
rm -rf mon-master/log/*
rm -rf mon-master/run/*
rm -f mgr-master/conf/ceph.conf
rm -f mgr-master/conf/ceph.client.admin.keyring
rm -f mgr-master/log/*
rm -rf mgr-master/run/*
rm -f osd-0/conf/ceph.conf
rm -f osd-0/log/*
rm -f osd-0/run/*
rm -f osd-1/conf/ceph.conf
rm -f osd-1/log/*
rm -f osd-1/run/*
rm -f osd-2/conf/ceph.conf
rm -f osd-2/log/*
rm -f osd-2/run/*
rm -f mds/conf/ceph.conf
rm -f mds/conf/ceph.client.admin.keyring
rm -f mds/run/*
rm -f rgw/conf/ceph.conf
rm -f rgw/run/*
rm -f rgw/log/*
rm -rf shared-data/*

if [ "$delete_volumes" -eq "1" ]; then
  rm -f "$OSD_VOLUME_DIR/osd1-volume"
  rm -f "$OSD_VOLUME_DIR/osd2-volume"
  rm -f "$OSD_VOLUME_DIR/osd3-volume"

  dd if=/dev/zero of=/storage/njordan/ceph/osd1-volume bs=1M count=5120
  dd if=/dev/zero of=/storage/njordan/ceph/osd2-volume bs=1M count=5120
  dd if=/dev/zero of=/storage/njordan/ceph/osd3-volume bs=1M count=5120
fi

osd1_dev=$(losetup -a | grep "$OSD_VOLUME_DIR/osd1-volume" | sed -e 's/:.*//')
if [ -z "$osd1_dev" ]; then
  losetup -f "$OSD_VOLUME_DIR/osd1-volume"
fi
osd2_dev=$(losetup -a | grep "$OSD_VOLUME_DIR/osd2-volume" | sed -e 's/:.*//')
if [ -z "$osd2_dev" ]; then
  losetup -f "$OSD_VOLUME_DIR/osd2-volume"
fi
osd3_dev=$(losetup -a | grep "$OSD_VOLUME_DIR/osd3-volume" | sed -e 's/:.*//')
if [ -z "$osd3_dev" ]; then
  losetup -f "$OSD_VOLUME_DIR/osd3-volume"
fi

sed -i -e 's#OSD1_DEV=.*#OSD1_DEV='"${osd1_dev}"'#' .env
sed -i -e 's#OSD2_DEV=.*#OSD2_DEV='"${osd2_dev}"'#' .env
sed -i -e 's#OSD3_DEV=.*#OSD3_DEV='"${osd3_dev}"'#' .env

