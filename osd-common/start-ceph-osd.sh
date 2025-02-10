#!/bin/bash

/usr/bin/ceph-osd \
    -i $1 \
    -f \
    --setuser ceph \
    --setgroup ceph \
    --default-log-to-file=false \
    --default-log-to-stderr=true
