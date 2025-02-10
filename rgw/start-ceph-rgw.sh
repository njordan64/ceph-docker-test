#!/bin/bash

/usr/bin/radosgw \
    --cluster ceph \
    -i rgw \
    -f \
    --setuser ceph \
    --setgroup ceph \
    --default-log-to-file=false \
    --default-log-to-stderr=true
