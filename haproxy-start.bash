#!/bin/bash
set -e

trap "exit" SIGHUP SIGINT SIGTERM

/haproxy-configure
/etcdctl-initial-lookup
etcdctl exec-watch --recursive /services/$HAPROXY_BACKEND -- /haproxy-update
