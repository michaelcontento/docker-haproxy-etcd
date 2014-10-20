# haproxy-etcd

[HAProxy][] docker container with servers stored in [etcd][].

# HAProxy configuration

The default command for this container is `web http` which would look for
backend servers in [etcd][]'s `/services/web` and would only route traffic on
port `80`.

This is rather limited so lets have a closer look at the command. The first
argument is the name of the "service group" (the folder in `/services/`).
Pretty easy, huh?

After the first fixed argument it gets more flexible, as everything else is
used to configure or enable some parts of the `haproxy.cfg`. The `http` of the
default command for example will enable the routing of port `80` traffic. Just
replace it with `https` and port `443` is open. And yes, you can combine them :)

## Simple `key=value` settings

It's possible to assign custom values to almost all commands and change their
effect. The syntax is always `key=value` and most of the time there are sane
defaults in place.

| Name                 | Default | Notes                                      |
|----------------------|---------|--------------------------------------------|
| maxconn              | 1000    | set `maxconn`                              |
| retries              | 3       | set `retries`                              |
| timeoutHttpRequest   | 10s     | set `timeout http-request`                 |
| timeoutClient        | 1m      | set `timeout client`                       |
| timeoutConnect       | 10s     | set `timeout connect`                      |
| timeoutServer        | 1m      | set `timeout server`                       |
| timeoutQueue         | 1m      | set `timeout queue`                        |
| timeoutHttpKeepAlive | 10s     | set `timeout http-keep-alive`              |
| timeoutCheck         | 5s      | set `timeout check`                        |
| httpCheck            | no      | `httpCheck=/ping` would active an http based healthcheck on the `/ping` URI |
| forceHttps           | no      | `yes` would redirect `http://` traffic to `https://`; `forceHttps` is equal to `forceHttps=yes` |

**Example:** `httpCheck=/api/v1/ping http https forceHttps` would enable a http
based healthcheck on `/api/v1/ping`, allow traffic on both port `80` and `443`
but everything on `80` is redirected to `443`.

## Complex keys

* `http`, `https` and `httpProxy` expect `bindIp:bindPort` as value
* `http` is equal to `http=*:80`
* `https` is equal to `https=*:443`
* Just name the port (like `http=80`, `https=443` or `httpsProxy=9050`) to use
  `*` as `bindHost`

**Example:** `http=127.0.0.1:80 https` would only allow http traffic from the
container itself but https traffic from everywhere.

## Stats

The stats key is a little bit more difficult, as you need to follow a specific
"uri schema" to set all required values.

**Schema**: `[user:pass@][realm://][bindIp:]bindPort/uri`

Some parts are optional and the minimal version would be something like
`stats=1234/stats`, which would bind to all interfaces on port `1234` and
expose everything under `/stats` with no user authentication. Not recommended!

* `stats=127.0.0.1:1234/stats` has still no authentication in place but limits
  the traffic source to `localhost`
* `stats=admin:password@127.0.0.1:1234/stats` now you need the very secret
  credentials to pass
* `stats=admin:password@Welcome!://127.0.0.1:1234/stats` same as above only
  with a custom realm name
* `stats=admin:password@1234/stats` is equal to `stats=admin:password@*:1234/stats`

## Debugging with `printConfig`

Just add `printConfig` and watch `stdout` to see the generated `haproxy.cfg`.

# etcd configuration

This container needs to talk with [etcd][] and for this you need to get it
somehow accessible.

But good news! This container comes with sane defaults, can be used with an
etcd-ambassador or you can just pass the right `IP:PORT` config as a simple
docker environment variable.

## Sane defaults

	docker run --rm -i \
		-t michaelcontento/haproxy-etcd

Would try to talk with `172.17.42.1:4001`.

## As docker environment variable

	docker run --rm -i \
		-e ETCDCTL_PEER=1.2.3.4:4001 \
		-t michaelcontento/haproxy-etcd

Would, as you might expect, talk to `1.2.3.4:4001`.

## With an etcd-ambassador

First start the ambassador container for [etcd][]:

	docker run --rm \
		--name etcd-amb-client \
		polvi/simple-amb ${COREOS_PRIVATE_IPV4}:4001

And now start your [haproxy-etcd][] and link the ambassador:

	docker run --rm \
		--link etcd-amb-client:etcd \
		michaelcontento/haproxy-etcd

[supervisord]: supervisord.org
[polvi/simple-amb]: https://registry.hub.docker.com/u/polvi/simple-amb/
[etcd]: https://github.com/coreos/etcd
[haproxy-etcd]: https://github.com/michaelcontento/docker-haproxy-etcd
[haproxy]: http://www.haproxy.org/
[redguava/docker-haproxy-etcd]: https://github.com/redguava/docker-haproxy-etcd
[dockerfile/haproxy]: https://github.com/dockerfile/haproxy
