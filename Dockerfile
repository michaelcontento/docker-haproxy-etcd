FROM dockerfile/haproxy

ENV ETCDCTL_PEER 172.17.42.1:4001

ADD haproxy.cfg /etc/haproxy/haproxy.cfg
ADD server.crt /etc/ssl/certs/server.crt

RUN URL_LATEST="https://github.com/coreos/etcd/releases/latest" \
    && VERSION=$(wget -qO- --no-check-certificate $URL_LATEST | egrep -o 'tag/v[v.0-9]*' | cut -d '/' -f2) \
    && URL_ETCD="https://github.com/coreos/etcd/releases/download/${VERSION}/etcd-${VERSION}-linux-amd64.tar.gz" \
    && wget --no-check-certificate --quiet $URL_ETCD \
    && tar -xzf etcd-*.tar.gz \
    && cp etcd-*/etcdctl /usr/bin/ \
    && rm -rf etcd-*

ADD bin/ /usr/local/bin

ENTRYPOINT ["bash", "haproxy-start"]
CMD ["web", "http"]
