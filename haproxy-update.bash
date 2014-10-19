#!/bin/bash
set -e

HAPROXY_CONFIG="/etc/haproxy/haproxy.cfg"

function update_globals
{
    if [[ $ETCD_WATCH_KEY == *HAPROXY_* ]]; then
        /haproxy-configure
    fi
}

function update_server
{
    HOST_NAME=$(echo $ETCD_WATCH_KEY | cut -d/ -f4)
    HOST_IP=$(echo $ETCD_WATCH_VALUE | tr -d '"{} ' | cut -d, -f1 | cut -d: -f2)
    HOST_PORT=$(echo $ETCD_WATCH_VALUE | tr -d '"{} ' | cut -d, -f2 | cut -d: -f2)

    if [[ $HOST_PORT == *.* ]]; then
        TMP=$HOST_IP
        HOST_IP=$HOST_PORT
        HOST_PORT=$TMP
    fi

    HAPROXY_BACKEND_SERVER_MAX_CONNECTIONS=$(/haproxy-config-get HAPROXY_BACKEND_SERVER_MAX_CONNECTIONS)

    if grep -q "server $HOST_NAME" $HAPROXY_CONFIG; then
        sed -i -e "s/  server ${HOST_NAME}.*$/  server $HOST_NAME ${HOST_IP}:${HOST_PORT} maxconn $HAPROXY_BACKEND_SERVER_MAX_CONNECTIONS check/g" $HAPROXY_CONFIG
    else
        echo "  server $HOST_NAME ${HOST_IP}:${HOST_PORT} maxconn $HAPROXY_BACKEND_SERVER_MAX_CONNECTIONS check" >> $HAPROXY_CONFIG
    fi
}

function remove_server
{
    HOST_NAME=$(echo $ETCD_WATCH_KEY | cut -d/ -f4)

    sed -i'' "/server $HOST_NAME /d" $HAPROXY_CONFIG
}

case $ETCD_WATCH_ACTION in
    compareAndSwap | update | set)
        if [[ $ETCD_WATCH_KEY == /config/* ]]; then
            update_globals
        else
            update_server
        fi
        ;;
    delete | expire)
        if [[ $ETCD_WATCH_KEY == /config/* ]]; then
            update_globals
        else
            remove_server
        fi
        ;;
    *)
        echo "Something went wrong..."
        exit 1
esac

/haproxy-restart
