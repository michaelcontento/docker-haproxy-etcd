FROM dockerfile/haproxy

ENV HAPROXY_BACKEND web
ENV ETCDCTL_PEER 172.17.42.1:4001

ADD haproxy.cfg /etc/haproxy/haproxy.cfg
ADD server.crt /etc/ssl/certs/server.crt

ADD etcdctl /usr/bin/etcdctl_original
ADD etcdctl-wrapper.bash /usr/bin/etcdctl
ADD etcdctl-initial-lookup.bash /etcdctl-initial-lookup
ADD haproxy-configure.bash /haproxy-configure
ADD haproxy-restart.bash /haproxy-restart
ADD haproxy-start.bash /haproxy-start
ADD haproxy-update.bash /haproxy-update
