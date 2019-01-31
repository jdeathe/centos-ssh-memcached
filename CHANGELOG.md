# Change Log

## centos-7

Summary of release changes for Version 2.

CentOS-7 7.5.1804 x86_64 - Memcached 1.4.

### 2.2.0 - Unreleased

- Updates source image to [2.5.0](https://github.com/jdeathe/centos-ssh/releases/tag/2.5.0).
- Updates and restructures Dockerfile.
- Adds placeholder replacement of `RELEASE_VERSION` docker argument to systemd service unit template.
- Adds error messages to healthcheck script and includes supervisord check.
- Removes use of `/etc/services-config` paths.
- Removes X-Fleet section from etcd register template unit-file.

### 2.1.1 - 2018-11-16

- Fixes typo in test; using `--format` instead of `--filter`.
- Adds required `--sysctl` settings to docker run templates.
- Updates source image to [2.4.1](https://github.com/jdeathe/centos-ssh/releases/tag/2.4.1).

### 2.1.0 - 2018-08-16

- Updates source image to [2.4.0](https://github.com/jdeathe/centos-ssh/releases/tag/2.4.0).

### 2.0.0 - 2018-05-12

- Initial release based on Memcached version 1.4.
