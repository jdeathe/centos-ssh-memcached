## Tags and respective `Dockerfile` links

- `centos-7`,[`2.3.0`](https://github.com/jdeathe/centos-ssh-memcached/releases/tag/2.3.0) [(centos-7/Dockerfile)](https://github.com/jdeathe/centos-ssh-memcached/blob/centos-7/Dockerfile)
- `centos-6`,[`1.4.0`](https://github.com/jdeathe/centos-ssh-memcached/releases/tag/1.4.0) [(centos-6/Dockerfile)](https://github.com/jdeathe/centos-ssh-memcached/blob/centos-6/Dockerfile)

## Overview

This build uses the base image [jdeathe/centos-ssh](https://github.com/jdeathe/centos-ssh) so inherits it's features but with `sshd` disabled by default. [Supervisor](http://supervisord.org/) is used to start the [`memcached`](https://github.com/memcached/memcached/wiki) daemon when a docker container based on this image is run.

### Image variants

- [Memcached 1.4 - CentOS-7](https://github.com/jdeathe/centos-ssh-memcached/tree/centos-7)
- [Memcached 1.4 - CentOS-6](https://github.com/jdeathe/centos-ssh-memcached/tree/centos-6)

## Quick start

> For production use, it is recommended to select a specific release tag as shown in the examples.

Run up a container named `memcached.1` from the docker image `jdeathe/centos-ssh-memcached` on port 11211 of your docker host.

```
$ docker run -d \
  --name memcached.1 \
  -p 11211:11211/tcp \
  --sysctl "net.core.somaxconn=1024" \
  jdeathe/centos-ssh-memcached:1.4.0
```

Verify the named container's process status and health.

```
$ docker ps -a \
	-f "name=memcached.1"
```

Verify successful initiallisation of the named container.

```
$ docker logs memcached.1
```

Verify the status of the `memcached` service that's running in the named container.

```
$ docker exec -it \
  memcached.1 \
  memcached-tool localhost stats
```

## Instructions

### Running

To run the a docker container from this image you can use the standard docker commands as shown in the example below. Alternatively, there's a [docker-compose](https://github.com/jdeathe/centos-ssh-memcached/blob/centos-7/docker-compose.yml) example.

For production use, it is recommended to select a specific release tag as shown in the examples.

#### Using environment variables

In the following example the `memcached` service is bound to port `11211` of the docker host. Also, the environment variable `MEMCACHED_CACHESIZE` has been used to set up a 32M memory based storage instead of the default 64M.

```
$ docker stop memcached.1 && \
  docker rm memcached.1 && \
  docker run \
  --detach \
  --name memcached.1 \
  --publish 11211:11211/tcp \
  --sysctl "net.core.somaxconn=1024" \
  --sysctl "net.ipv4.ip_local_port_range=1024 65535" \
  --sysctl "net.ipv4.route.flush=1" \
  --env "MEMCACHED_CACHESIZE=32" \
  jdeathe/centos-ssh-memcached:1.4.0
```

### Environment variables

Environment variables are available, as detailed below, to allow the operator to configure a container on run. Environment variable values cannot be changed after running the container; it's a one-shot type setting. If you need to change a value you have to terminate, (i.e stop and remove), and replace the running container.

#### ENABLE_MEMCACHED_WRAPPER

It may be desirable to prevent the startup of the memcached-wrapper script. For example, when using an image built from this Dockerfile as the source for another Dockerfile you could disable memcached from startup by setting `ENABLE_MEMCACHED_WRAPPER` to `false`. The benefit of this is to reduce the number of running processes in the final container. Another use for this would be to make use of the packages installed in the image such as `memcached-tool` or the libmemcached tools `memcp`, `memcat`, `memrm` and `memflush`; effectively making the container a Memcached client.

#### MEMCACHED_CACHESIZE

Use `MEMCACHED_CACHESIZE` MB memory max to use for object storage; the default is 64 megabytes. 

#### MEMCACHED_MAXCONN

Use `MEMCACHED_MAXCONN` max simultaneous connections; the default is 1024.

#### MEMCACHED_OPTIONS

Use `MEMCACHED_OPTIONS` to set other memcached options. The default is `-U 0` which disables UDP.
