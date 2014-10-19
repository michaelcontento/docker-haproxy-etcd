#!/bin/bash
set -e

if [ $# -eq 0 ]; then
    echo "usage: haproxy-config-get CONFIG_NAME"
    exit 1
fi
CONFIG_NAME=$1

HAPROXY_BACKEND_SERVICE=$(etcdctl get /config/HAPROXY_BACKEND_SERVICE \
    || echo "$HAPROXY_BACKEND_SERVICE" )

if [ "$CONFIG_NAME" == "HAPROXY_BACKEND_SERVICE" ]; then
    echo $HAPROXY_BACKEND_SERVICE
    exit 0
fi

etcdctl get /config/$HAPROXY_BACKEND_SERVICE/$CONFIG_NAME \
    || etcdctl get /config/$CONFIG_NAME \
    || echo ${!CONFIG_NAME}
