#!/bin/bash

if [ ! -f etcdctl ]; then
  cp /usr/bin/etcdctl .
fi
docker build -t michaelcontento/haproxy-etcd .
