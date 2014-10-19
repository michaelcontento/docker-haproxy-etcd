FROM dockerfile/haproxy

ENV ETCDCTL_PEER 172.17.42.1:4001
ENV HAPROXY_BACKEND_SERVICE web
ENV HAPROXY_GLOBAL_MAX_CONNECTIONS 2000
ENV HAPROXY_DEFAULTS_MAX_CONNECTIONS 1000
ENV HAPROXY_DEFAULTS_RETRIES 3
ENV HAPROXY_DEFAULTS_TIMEOUT_HTTP_REQUEST 10s
ENV HAPROXY_DEFAULTS_TIMEOUT_CLIENT 1m
ENV HAPROXY_DEFAULTS_TIMEOUT_CONNECT 10s
ENV HAPROXY_DEFAULTS_TIMEOUT_SERVER 1m
ENV HAPROXY_DEFAULTS_TIMEOUT_QUEUE 1m
ENV HAPROXY_DEFAULTS_TIMEOUT_HTTP_KEEP_ALIVE 10s
ENV HAPROXY_DEFAULTS_OPTION_HTTPCHK \/healthcheck
ENV HAPROXY_DEFAULTS_TIMEOUT_CHECK 5s
ENV HAPROXY_DEFAULTS_SPREAD_CHECKS 5
ENV HAPROXY_DEFAULTS_MONITOR_URI \/monitor
ENV HAPROXY_STATS_PORT 8080
ENV HAPROXY_STATS_ENABLE enable
ENV HAPROXY_STATS_URI \/stats
ENV HAPROXY_STATS_REALM Statistics
ENV HAPROXY_STATS_USERNAME username
ENV HAPROXY_STATS_PASSWORD pass
ENV HAPROXY_BACKEND_SERVER_MAX_CONNECTIONS 32

ADD haproxy.cfg /etc/haproxy/haproxy.cfg
ADD server.crt /etc/ssl/certs/server.crt

RUN URL_LATEST="https://github.com/coreos/etcd/releases/latest" \
	&& VERSION=$(curl -I $URL_LATEST 2>/dev/null | egrep -o 'tag/v[v.0-9]*' | cut -d '/' -f2) \
	&& URL_ETCD="https://github.com/coreos/etcd/releases/download/${VERSION}/etcd-${VERSION}-linux-amd64.tar.gz" \
	&& wget --quiet $URL_ETCD \
	&& tar -xzf etcd-*.tar.gz \
	&& cp etcd-*/etcdctl /usr/bin/etcdctl_original \
	&& rm -rf etcd-*

ADD etcdctl-wrapper.bash /usr/bin/etcdctl
ADD etcdctl-initial-lookup.bash /etcdctl-initial-lookup
ADD haproxy-config-get.bash /haproxy-config-get
ADD haproxy-configure.bash /haproxy-configure
ADD haproxy-restart.bash /haproxy-restart
ADD haproxy-start.bash /haproxy-start
ADD haproxy-update.bash /haproxy-update
