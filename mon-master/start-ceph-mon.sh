#!/bin/bash

/usr/bin/ceph-mon \
    -n mon.mon-master \
    -f \
    --setuser ceph \
    --setgroup ceph \
    --default-log-to-file=false \
    --default-log-to-stderr=true \
    --default-log-stderr-prefix=debug \
    --default-mon-cluster-log-to-file=false \
    --default-mon-cluster-log-to-stderr=true
