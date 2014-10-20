FROM debian:wheezy

ENV ETCDCTL_PEER 172.17.42.1:4001

RUN export DEBIAN_FRONTEND=noninteractive \
    && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && echo "deb http://cdn.debian.net/debian/ wheezy-backports main" > /etc/apt/sources.list.d/backports.list \
    && apt-get update \
    && apt-get install --yes --no-install-recommends wget haproxy -t wheezy-backports \
    && service haproxy stop \
    && update-rc.d -f haproxy remove \
    && rm -rf /var/lib/apt/lists/*

RUN URL_LATEST="https://github.com/coreos/etcd/releases/latest" \
    && VERSION=$(wget -qO- --no-check-certificate $URL_LATEST | egrep -o 'tag/v[v.0-9]*' | cut -d '/' -f2) \
    && URL_ETCD="https://github.com/coreos/etcd/releases/download/${VERSION}/etcd-${VERSION}-linux-amd64.tar.gz" \
    && wget --no-check-certificate --quiet $URL_ETCD \
    && tar -xzf etcd-*.tar.gz \
    && cp etcd-*/etcdctl /usr/bin/ \
    && rm -rf etcd-*

ADD haproxy.cfg /etc/haproxy/haproxy.cfg
ADD server.crt /etc/ssl/certs/server.crt
ADD bin/ /usr/local/bin

ENTRYPOINT ["haproxy-start"]
CMD ["web", "http"]
