FROM dockerfile/haproxy

ENV HAPROXY_BACKEND web
ENV ETCDCTL_PEER 172.17.42.1:4001

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
ADD haproxy-configure.bash /haproxy-configure
ADD haproxy-restart.bash /haproxy-restart
ADD haproxy-start.bash /haproxy-start
ADD haproxy-update.bash /haproxy-update
