#!/bin/bash
set -e

# Support etc ambassador polvi/simple-amb
LINKED_ETCDCTL_PEER="${ETCD_PORT_10000_TCP_ADDR}:${ETCD_PORT_10000_TCP_PORT}"
if [ "$LINKED_ETCDCTL_PEER" != ":" ]; then
    ETCDCTL_PEER="$LINKED_ETCDCTL_PEER"
fi

# Suppress error messages and favour a clean log
etcdctl_original --peers $ETCDCTL_PEER $@ 2>/dev/null
