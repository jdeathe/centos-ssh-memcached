# Change Log

## 2 - centos-7

Summary of release changes.

### 2.3.1 - Unreleased

- Fixes CentOS-7 version in Dockerfile `org.deathe.description` metadata.

### 2.3.0 - 2019-06-25

- Deprecates `MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER`, replaced with `ENABLE_MEMCACHED_WRAPPER`.
- Updates source image to [2.6.0](https://github.com/jdeathe/centos-ssh/releases/tag/2.6.0).
- Updates CHANGELOG.md to simplify maintenance.
- Updates README.md to simplify contents and improve readability.
- Updates README-short.txt to apply to all image variants.
- Updates Dockerfile `org.deathe.description` metadata LABEL for consistency.
- Updates `memcached-wrapper` configuration to send error log output to stderr.
- Updates `memcached-wrapper` timer to use UTC date timestamps.
- Updates wrapper supervisord configuration file/priority to `50-memcached-wrapper.conf`/`50`.
- Fixes binary paths in systemd unit files; missing changes from last release.
- Fixes docker host connection status check in Makefile.
- Adds missing instruction step to docker-compose example configuration file.
- Adds `inspect`, `reload` and `top` Makefile targets.
- Adds improved `clean` Makefile target; includes exited containers and dangling images.
- Adds lock/state file to wrapper script.
- Adds `SYSTEM_TIMEZONE` handling to Makefile, scmi, systemd unit and docker-compose templates.
- Adds system time zone validation to healthcheck.
- Removes support for long image tags (i.e. centos-7-2.x.x).

### 2.2.1 - 2019-03-20

- Updates source image to [2.5.1](https://github.com/jdeathe/centos-ssh/releases/tag/2.5.1).
- Updates Dockerfile with combined ADD to reduce layer count in final image.
- Fixes binary paths in systemd unit files for compatibility with both EL and Ubuntu hosts.
- Adds improvement to pull logic in systemd unit install template.
- Adds `SSH_AUTOSTART_SUPERVISOR_STDOUT` with a value "false", disabling startup of `supervisor_stdout`.
- Adds improved `healtchcheck` and `memcached-wrapper` scripts.
- Adds `docker-compose.yml` to `.dockerignore`.

### 2.2.0 - 2019-02-12

- Updates source image to [2.5.0](https://github.com/jdeathe/centos-ssh/releases/tag/2.5.0).
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

### 2.1.1 - 2018-11-16

- Fixes typo in test; using `--format` instead of `--filter`.
- Adds required `--sysctl` settings to docker run templates.
- Updates source image to [2.4.1](https://github.com/jdeathe/centos-ssh/releases/tag/2.4.1).

### 2.1.0 - 2018-08-16

- Updates source image to [2.4.0](https://github.com/jdeathe/centos-ssh/releases/tag/2.4.0).

### 2.0.0 - 2018-05-12

- Initial release based on Memcached version 1.4.
