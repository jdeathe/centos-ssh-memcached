# Change Log

## centos-6

Summary of release changes for Version 1.

CentOS-6 6.8 x86_64 - Memcached 1.4.

### 1.2.0 - Unreleased

- Fixes issue with expect script failure when using `expect -f`.
- Adds `SHPEC_ROOT` variable to Makefile.

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
