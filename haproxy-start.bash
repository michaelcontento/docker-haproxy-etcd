#!/bin/bash
set -e

trap "exit" SIGHUP SIGINT SIGTERM

/haproxy-configure
/etcdctl-initial-lookup

HAPROXY_BACKEND_SERVICE=$(/haproxy-config-get HAPROXY_BACKEND_SERVICE)
etcdctl exec-watch --recursive /services/$HAPROXY_BACKEND_SERVICE -- /haproxy-update
