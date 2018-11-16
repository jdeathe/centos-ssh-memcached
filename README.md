centos-ssh-memcached
====================

Docker Image including:

- CentOS-6 6.10 x86_64 and Memcached 1.4.
- CentOS-7 7.5.1804 x86_64 and Memcached 1.4.

## Overview & links

The latest CentOS-6 / CentOS-7 based releases can be pulled from the `centos-6` / `centos-7` Docker tags respectively. For production use it is recommended to select a specific release tag - the convention is `centos-6-1.2.0` OR `1.2.0` for the [1.2.0](https://github.com/jdeathe/centos-ssh-memcached/tree/1.2.0) release tag and `centos-7-2.1.0` OR `2.1.0` for the [2.1.0](https://github.com/jdeathe/centos-ssh/tree/2.1.0) release tag.

### Tags and respective `Dockerfile` links

- `centos-7`,`centos-7-2.1.0`,`2.1.0` [(centos-7/Dockerfile)](https://github.com/jdeathe/centos-ssh-memcached/blob/centos-7/Dockerfile)
- `centos-6`,`centos-6-1.2.0`,`1.2.0` [(centos-6/Dockerfile)](https://github.com/jdeathe/centos-ssh-memcached/blob/centos-6/Dockerfile)

Included in the build are the [SCL](https://www.softwarecollections.org/), [EPEL](http://fedoraproject.org/wiki/EPEL) and [IUS](https://ius.io) repositories. Installed packages include [OpenSSH](http://www.openssh.com/portable.html) secure shell, [vim-minimal](http://www.vim.org/), are installed along with python-setuptools, [supervisor](http://supervisord.org/) and [supervisor-stdout](https://github.com/coderanger/supervisor-stdout).

Supervisor is used to start the memcached (and optionally the sshd) daemon when a docker container based on this image is run. To enable simple viewing of stdout for the service's subprocess, supervisor-stdout is included. This allows you to see output from the supervisord controlled subprocesses with `docker logs {docker-container-name}`.

If enabling and configuring SSH access, it is by public key authentication and, by default, the [Vagrant](http://www.vagrantup.com/) [insecure private key](https://github.com/mitchellh/vagrant/blob/master/keys/vagrant) is required.

### SSH Alternatives

SSH is not required in order to access a terminal for the running container. The simplest method is to use the docker exec command to run bash (or sh) as follows: 

```
$ docker exec -it {docker-name-or-id} bash
```

For cases where access to docker exec is not possible the preferred method is to use Command Keys and the nsenter command.

## Quick Example

Run up a container named `memcached.pool-1.1.1` from the docker image `jdeathe/centos-ssh-memcached` on port 11211 of your docker host.

```
$ docker run -d \
  --name memcached.pool-1.1.1 \
  -p 11211:11211/tcp \
  --sysctl "net.core.somaxconn=1024" \
  jdeathe/centos-ssh-memcached:2.1.0
```

Now you can verify it is initialised and running successfully by inspecting the container's logs.

```
$ docker logs memcached.pool-1.1.1
```

To verify the Memcached service status:

```
$ docker exec -it \
  memcached.pool-1.1.1 \
  memcached-tool localhost stats
```

## Instructions

### Running

To run the a docker container from this image you can use the standard docker commands. Alternatively, if you have a checkout of the [source repository](https://github.com/jdeathe/centos-ssh-memcached), and have make installed the Makefile provides targets to build, install, start, stop etc. where environment variables can be used to configure the container options and set custom docker run parameters.

In the following example the memcached service is bound to port 11211 of the docker host. Also, the environment variable `MEMCACHED_CACHESIZE` has been used to set up a 32M memory based storage instead of the default 64M.

#### Using environment variables

```
$ docker stop memcached.pool-1.1.1 && \
  docker rm memcached.pool-1.1.1
$ docker run \
  --detach \
  --tty \
  --name memcached.pool-1.1.1 \
  --publish 11211:11211/tcp \
  --sysctl "net.core.somaxconn=1024" \
  --sysctl "net.ipv4.ip_local_port_range=1024 65535" \
  --sysctl "net.ipv4.route.flush=1" \
  --env "MEMCACHED_CACHESIZE=32" \
  jdeathe/centos-ssh-memcached:2.1.0
```

#### Environment Variables

There are environmental variables available which allows the operator to customise the running container.

##### MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER

It may be desirable to prevent the startup of the memcached-wrapper script. For example, when using an image built from this Dockerfile as the source for another Dockerfile you could disable memcached from startup by setting `MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER` to `false`. The benefit of this is to reduce the number of running processes in the final container. Another use for this would be to make use of the packages installed in the image such as `memcached-tool` or the libmemcached tools `memcp`, `memcat`, `memrm` and `memflush`; effectively making the container a Memcached client.

##### MEMCACHED_CACHESIZE

Use `MEMCACHED_CACHESIZE` MB memory max to use for object storage; the default is 64 megabytes. 

##### MEMCACHED_MAXCONN

Use `MEMCACHED_MAXCONN` max simultaneous connections; the default is 1024.

##### MEMCACHED_OPTIONS

Use `MEMCACHED_OPTIONS` to set other memcached options. The default is `-U 0` which disables UDP.
