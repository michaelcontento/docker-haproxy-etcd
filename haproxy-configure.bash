#!/bin/bash
set -e

HAPROXY_GLOBAL_MAX_CONNECTIONS=$(/haproxy-config-get HAPROXY_GLOBAL_MAX_CONNECTIONS)
HAPROXY_DEFAULTS_MAX_CONNECTIONS=$(/haproxy-config-get HAPROXY_DEFAULTS_MAX_CONNECTIONS)
HAPROXY_DEFAULTS_RETRIES=$(/haproxy-config-get HAPROXY_DEFAULTS_RETRIES)
HAPROXY_DEFAULTS_TIMEOUT_HTTP_REQUEST=$(/haproxy-config-get HAPROXY_DEFAULTS_TIMEOUT_HTTP_REQUEST)
HAPROXY_DEFAULTS_TIMEOUT_CLIENT=$(/haproxy-config-get HAPROXY_DEFAULTS_TIMEOUT_CLIENT)
HAPROXY_DEFAULTS_TIMEOUT_CONNECT=$(/haproxy-config-get HAPROXY_DEFAULTS_TIMEOUT_CONNECT)
HAPROXY_DEFAULTS_TIMEOUT_SERVER=$(/haproxy-config-get HAPROXY_DEFAULTS_TIMEOUT_SERVER)
HAPROXY_DEFAULTS_TIMEOUT_QUEUE=$(/haproxy-config-get HAPROXY_DEFAULTS_TIMEOUT_QUEUE)
HAPROXY_DEFAULTS_TIMEOUT_HTTP_KEEP_ALIVE=$(/haproxy-config-get HAPROXY_DEFAULTS_TIMEOUT_HTTP_KEEP_ALIVE)
HAPROXY_DEFAULTS_OPTION_HTTPCHK=$(/haproxy-config-get HAPROXY_DEFAULTS_OPTION_HTTPCHK)
HAPROXY_DEFAULTS_TIMEOUT_CHECK=$(/haproxy-config-get HAPROXY_DEFAULTS_TIMEOUT_CHECK)
HAPROXY_DEFAULTS_SPREAD_CHECKS=$(/haproxy-config-get HAPROXY_DEFAULTS_SPREAD_CHECKS)
HAPROXY_DEFAULTS_MONITOR_URI=$(/haproxy-config-get HAPROXY_DEFAULTS_MONITOR_URI)
HAPROXY_STATS_PORT=$(/haproxy-config-get HAPROXY_STATS_PORT)
HAPROXY_STATS_ENABLE=$(/haproxy-config-get HAPROXY_STATS_ENABLE)
HAPROXY_STATS_URI=$(/haproxy-config-get HAPROXY_STATS_URI)
HAPROXY_STATS_REALM=$(/haproxy-config-get HAPROXY_STATS_REALM)
HAPROXY_STATS_USERNAME=$(/haproxy-config-get HAPROXY_STATS_USERNAME)
HAPROXY_STATS_PASSWORD=$(/haproxy-config-get HAPROXY_STATS_PASSWORD)
HAPROXY_FORCE_HTTPS=$(/haproxy-config-get HAPROXY_FORCE_HTTPS)

# create fresh working copy from base template
WORKING_CONFIG=/tmp/haproxy.cfg
cp -f /etc/haproxy/haproxy.cfg.tpl $WORKING_CONFIG

sed -i -e "s/HAPROXY_GLOBAL_MAX_CONNECTIONS/$HAPROXY_GLOBAL_MAX_CONNECTIONS/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_DEFAULTS_MAX_CONNECTIONS/$HAPROXY_DEFAULTS_MAX_CONNECTIONS/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_DEFAULTS_RETRIES/$HAPROXY_DEFAULTS_RETRIES/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_DEFAULTS_TIMEOUT_HTTP_REQUEST/$HAPROXY_DEFAULTS_TIMEOUT_HTTP_REQUEST/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_DEFAULTS_TIMEOUT_CLIENT/$HAPROXY_DEFAULTS_TIMEOUT_CLIENT/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_DEFAULTS_TIMEOUT_CONNECT/$HAPROXY_DEFAULTS_TIMEOUT_CONNECT/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_DEFAULTS_TIMEOUT_SERVER/$HAPROXY_DEFAULTS_TIMEOUT_SERVER/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_DEFAULTS_TIMEOUT_QUEUE/$HAPROXY_DEFAULTS_TIMEOUT_QUEUE/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_DEFAULTS_TIMEOUT_HTTP_KEEP_ALIVE/$HAPROXY_DEFAULTS_TIMEOUT_HTTP_KEEP_ALIVE/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_DEFAULTS_OPTION_HTTPCHK/$HAPROXY_DEFAULTS_OPTION_HTTPCHK/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_DEFAULTS_TIMEOUT_CHECK/$HAPROXY_DEFAULTS_TIMEOUT_CHECK/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_DEFAULTS_SPREAD_CHECKS/$HAPROXY_DEFAULTS_SPREAD_CHECKS/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_DEFAULTS_MONITOR_URI/$HAPROXY_DEFAULTS_MONITOR_URI/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_STATS_PORT/$HAPROXY_STATS_PORT/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_STATS_ENABLE/$HAPROXY_STATS_ENABLE/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_STATS_URI/$HAPROXY_STATS_URI/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_STATS_REALM/$HAPROXY_STATS_REALM/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_STATS_USERNAME/$HAPROXY_STATS_USERNAME/g" $WORKING_CONFIG
sed -i -e "s/HAPROXY_STATS_PASSWORD/$HAPROXY_STATS_PASSWORD/g" $WORKING_CONFIG
if [ "$HAPROXY_FORCE_HTTPS" == "no" ]; then
    sed -i "/redirect scheme https/d" $WORKING_CONFIG
fi

# copy previously defined server records
grep '^  server .* maxconn .*$' /etc/haproxy/haproxy.cfg \
	>> $WORKING_CONFIG \
	|| true

mv -f $WORKING_CONFIG /etc/haproxy/haproxy.cfg
