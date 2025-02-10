#!/bin/bash

/usr/bin/ceph-mgr \
    -i mgr-master \
    -f \
    --setuser ceph \
    --setgroup ceph \
    --default-log-to-file=false \
    --default-log-to-stderr=true
