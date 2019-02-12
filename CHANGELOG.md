# Change Log

## centos-6

Summary of release changes for Version 1.

CentOS-6 6.10 x86_64 - Memcached 1.4.

### 1.3.0 - 2019-02-12

- Updates source image to [1.10.0](https://github.com/jdeathe/centos-ssh/releases/tag/1.10.0).
- Updates and restructures Dockerfile.
- Updates default HEALTHCHECK interval to 1 second from 0.5.
- Updates container naming conventions and readability of `Makefile`.
- Fixes issue with unexpected published port in run templates when `DOCKER_PORT_MAP_TCP_11211` is set to an empty string or 0.
- Adds placeholder replacement of `RELEASE_VERSION` docker argument to systemd service unit template.
- Adds error messages to healthcheck script and includes supervisord check.
- Adds consideration for event lag into test cases for unhealthy health_status events.
- Adds port incrementation to Makefile's run template for container names with an instance suffix.
- Adds improved memcached-wrapper script including optional Details output.
- Adds validation on `MEMCACHED_CACHESIZE` and `MEMCACHED_MAXCONN` - fails back to default if not a positive non-zero integer.
- Adds docker-compose configuration example.
- Adds improved logging output.
- Removes use of `/etc/services-config` paths.
- Removes X-Fleet section from etcd register template unit-file.
- Removes the unused group element from the default container name.
- Removes the node element from the default container name.
- Removes unused environment variables from Makefile and scmi configuration.
- Removes container log file `/var/log/memcached.log`.

### 1.2.1 - 2018-11-16

- Fixes typo in test; using `--format` instead of `--filter`.
- Adds required `--sysctl` settings to docker run templates.
- Updates source image to [1.9.1](https://github.com/jdeathe/centos-ssh/releases/tag/1.9.1).

### 1.2.0 - 2018-08-16

- Adds details of the centos-7 (Version 2) branch to the README.
- Updates source image to [1.9.0](https://github.com/jdeathe/centos-ssh/releases/tag/1.9.0).

### 1.1.3 - 2018-05-13

- Updates source image to [1.8.4 tag](https://github.com/jdeathe/centos-ssh/releases/tag/1.8.4).

### 1.1.2 - 2018-01-13

- Updates source image to [1.8.3 tag](https://github.com/jdeathe/centos-ssh/releases/tag/1.8.3).
- Adds a `.dockerignore` file.

### 1.1.1 - 2017-09-15

- Updates source image to [1.8.2 tag](https://github.com/jdeathe/centos-ssh/releases/tag/1.8.2).

### 1.1.0 - 2017-08-08

- Fixes issue with expect script failure when using `expect -f`.
- Adds `SHPEC_ROOT` variable to Makefile.
- Removes scmi; it's maintained [upstream](https://github.com/jdeathe/centos-ssh/blob/centos-6/src/usr/sbin/scmi).
- Adds use of readonly variables for constants.
- Updates source image to [1.8.1 tag](https://github.com/jdeathe/centos-ssh/releases/tag/1.8.1).
- Adds a `src` directory for the image root files.
- Adds `STARTUP_TIME` variable for the `logs-delayed` Makefile target.
- Adds test case output with improved readability.
- Adds healthcheck.
- Adds [libmemcached](http://libmemcached.org/) to image.
- Adds `MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER` to optionally disable process startup.

### 1.0.1 - 2017-05-22

- Adds source from [jdeathe/centos-ssh:1.7.6](https://github.com/jdeathe/centos-ssh/releases/tag/1.7.6)
- Updates memcached package to `memcached-1.4.4-5.el6`.
- Adds a change log (`CHANGELOG.md`).
- Adds support for semantic version numbered tags.
- Adds minor code style changes to the Makefile for readability.
- Adds support for running `shpec` functional tests with `make test`.
- Adds correct spelling of Memcached in log file path: `/var/log/memcached.log`.
- Replaces deprecated Dockerfile `MAINTAINER` with a `LABEL`.

### 1.0.0 - 2016-11-23

- Initial release based on Memcached version 1.4.
