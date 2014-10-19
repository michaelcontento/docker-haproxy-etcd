# haproxy-etcd

[HAProxy][] docker container which loads all options and server definitions
from [coreos/etcd][].

Heavily inspired and based on [redguava/docker-haproxy-etcd][] but with quite a
few addition / changes.

*BUT* it should be API compatible with [redguava/docker-haproxy-etcd][] and
existing setups should be very trivial to migrate.

# Differences

* Based on `dockerfiles/haproxy` instead of `redguava/docker-haproxy`
* Thus reduced image size (427.4MB instead of 719.6MB)
* Order of `IP` and `PORT` in server config is no longer important
* Supports etcd ambassador via [polvi/simple-amb][]
* Adds `HAPROXY_FORCE_HTTPS` config variable (default: yes)
* Restarts [haproxy][] only if config has changes (md5 checksum based)
* It's possible to declare configuration as docker ENV variable
* `ETCDCTL_PEER` can be set via docker ENV variable too
* Multi-level config loading (`/config/$BACKEND/$KEY` -> `/config/$KEY` -> `ENV[$KEY]`)
* Replaced [supervisord][] setup with a few simple `bash` scripts
* Detect and apply changes in [coreos/etcd][] keyspace `/config/` too

# Examples

## Example: CoreOS + etcd-Ambassador

	# Expose CoreOS etcd
	docker run --rm \
		--name etcd-amb-client \
		polvi/simple-amb ${COREOS_PRIVATE_IPV4}:4001

	# Run haproxy with servers configured in /services/frontend
	docker run --rm \
		--link etcd-amb-client:etcd \
		--name frontend-haproxy \
		-e HAPROXY_BACKEND_SERVICE=frontend \
		-p 80:80 \
		-p 443:443 \
		michaelcontento/haproxy-etcd

## Example: Default etcd location

	# Same as above but this time the default etcd location is used
	docker run --rm \
		--name frontend-haproxy \
		-e HAPROXY_BACKEND_SERVICE=frontend \
		-p 80:80 \
		-p 443:443 \
		michaelcontento/haproxy-etcd

## Example: Use global configuration in etcd

	# Same as above but this time we load the server namespace from etcd
	etcdctl set /config/HAPROXY_BACKEND_SERVICE frontend
	docker run --rm \
		--name frontend-haproxy \
		-p 80:80 \
		-p 443:443 \
		michaelcontento/haproxy-etcd

## Example: Use global and backend-level configuration in etcd

	# Same as above but with additional configuration on backend level
	etcdctl set /config/HAPROXY_BACKEND_SERVICE frontend
	etcdctl set /config/frontend/HAPROXY_FORCE_HTTPS no
	docker run --rm \
		--name frontend-haproxy \
		-p 80:80 \
		-p 443:443 \
		michaelcontento/haproxy-etcd

## Example: Configuration value resolution

	etcdctl set /config/HAPROXY_BACKEND_SERVICE global
	etcdctl set /config/global/HAPROXY_BACKEND_SERVICE backendlevel
	docker run --rm michaelcontento/haproxy-etcd -e HAPROXY_BACKEND_SERVICE=env
	# Result: backendlevel

	etcdctl set /config/HAPROXY_BACKEND_SERVICE global
	docker run --rm michaelcontento/haproxy-etcd -e HAPROXY_BACKEND_SERVICE=env
	# Result: global

	docker run --rm michaelcontento/haproxy-etcd -e HAPROXY_BACKEND_SERVICE=env
	# Result: env

	docker run --rm michaelcontento/haproxy-etcd
	# Result: default defined in Dockerfile


[supervisord]: supervisord.org
[polvi/simple-amb]: https://registry.hub.docker.com/u/polvi/simple-amb/
[coreos/etcd]: https://github.com/coreos/etcd
[haproxy]: http://www.haproxy.org/
[redguava/docker-haproxy-etcd]: https://github.com/redguava/docker-haproxy-etcd
[dockerfile/haproxy]: https://github.com/dockerfile/haproxy
