#!/bin/bash
set -e

CHECKSUM="$(cat /etc/haproxy/haproxy.cfg | sort | md5sum)"
if [ "$CHECKSUM" != "$(cat /etc/haproxy/haproxy.cfg.md5 2>/dev/null)" ]; then
	echo "haproxy reloaded/started"
	echo "$CHECKSUM" > /etc/haproxy/haproxy.cfg.md5
	haproxy \
		-f /etc/haproxy/haproxy.cfg \
		-p /var/run/haproxy.pid \
		-sf $(cat /var/run/haproxy.pid 2>/dev/null)
fi
