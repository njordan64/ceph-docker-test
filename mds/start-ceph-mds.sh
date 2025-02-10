#!/bin/bash

/usr/bin/ceph-mds \
    -i mds \
    -m mon-master:3300 \
    -f \
    --setuser ceph \
    --setgroup ceph \
    --default-log-to-file=false \
    --default-log-to-stderr=true
