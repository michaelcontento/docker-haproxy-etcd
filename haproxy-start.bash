#!/bin/bash
set -e

trap "exit" SIGHUP SIGINT SIGTERM

/haproxy-configure
/etcdctl-initial-lookup

HAPROXY_BACKEND_SERVICE=$(etcdctl get /config/HAPROXY_BACKEND_SERVICE || echo "$HAPROXY_BACKEND_SERVICE")
etcdctl exec-watch --recursive /services/$HAPROXY_BACKEND_SERVICE -- /haproxy-update
