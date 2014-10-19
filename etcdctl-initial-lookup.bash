#!/bin/bash
set -e

NODES=$(etcdctl ls --recursive /services/$HAPROXY_BACKEND)

for NODE_NAME in $NODES; do
	NODE_VALUE=$(etcdctl get $NODE_NAME)
	ETCD_WATCH_ACTION="set" ETCD_WATCH_KEY=$NODE_NAME ETCD_WATCH_VALUE=$NODE_VALUE /haproxy-update
done
