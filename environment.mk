# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------
DOCKER_USER := jdeathe
DOCKER_IMAGE_NAME := centos-ssh-memcached
SHPEC_ROOT := test/shpec

# Tag validation patterns
DOCKER_IMAGE_TAG_PATTERN := ^(latest|centos-[6-7]|((1|2|centos-(6-1|7-2))\.[0-9]+\.[0-9]+))$
DOCKER_IMAGE_RELEASE_TAG_PATTERN := ^(1|2|centos-(6-1|7-2))\.[0-9]+\.[0-9]+$

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

# Docker image/container settings
DOCKER_CONTAINER_OPTS ?=
DOCKER_IMAGE_TAG ?= latest
DOCKER_NAME ?= memcached.pool-1.1.1
DOCKER_PORT_MAP_TCP_22 ?= NULL
DOCKER_PORT_MAP_TCP_11211 ?= 11211
DOCKER_PORT_MAP_UDP_11211 ?= NULL
DOCKER_RESTART_POLICY ?= always

# Docker build --no-cache parameter
NO_CACHE ?= false

# Directory path for release packages
DIST_PATH ?= ./dist

# Number of seconds expected to complete container startup including bootstrap.
STARTUP_TIME ?= 1

# ------------------------------------------------------------------------------
# Application container configuration
# ------------------------------------------------------------------------------
SSH_AUTHORIZED_KEYS ?=
SSH_AUTOSTART_SSHD ?= false
SSH_AUTOSTART_SSHD_BOOTSTRAP ?= false
SSH_CHROOT_DIRECTORY ?= %h
SSH_INHERIT_ENVIRONMENT ?= false
SSH_SUDO ?= ALL=(ALL) ALL
SSH_USER ?= app-admin
SSH_USER_FORCE_SFTP ?= false
SSH_USER_HOME ?= /home/%u
SSH_USER_ID ?= 500:500
SSH_USER_PASSWORD ?=
SSH_USER_PASSWORD_HASHED ?= false
SSH_USER_SHELL ?= /bin/bash
# ------------------------------------------------------------------------------
MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER ?= true
MEMCACHED_CACHESIZE ?= 64
MEMCACHED_MAXCONN ?= 1024
MEMCACHED_OPTIONS ?= -U 0