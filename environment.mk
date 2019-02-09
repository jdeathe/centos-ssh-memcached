# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
DOCKER_USER := jdeathe
DOCKER_IMAGE_NAME := centos-ssh-memcached
SHPEC_ROOT := test/shpec

# Tag validation patterns
DOCKER_IMAGE_TAG_PATTERN := ^(latest|centos-6|((1|centos-6-1)\.[0-9]+\.[0-9]+))$
DOCKER_IMAGE_RELEASE_TAG_PATTERN := ^(1|centos-6-1)\.[0-9]+\.[0-9]+$

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

# Docker --sysctl settings
SYSCTL_NET_CORE_SOMAXCONN ?= 1024
SYSCTL_NET_IPV4_IP_LOCAL_PORT_RANGE ?= 1024 65535
SYSCTL_NET_IPV4_ROUTE_FLUSH ?= 1

# Docker image/container settings
DOCKER_CONTAINER_OPTS ?=
DOCKER_IMAGE_TAG ?= latest
DOCKER_NAME ?= memcached.1
DOCKER_PORT_MAP_TCP_11211 ?= 11211
DOCKER_PORT_MAP_UDP_11211 ?= NULL
DOCKER_RESTART_POLICY ?= always

# Docker build --no-cache parameter
NO_CACHE ?= false

# Directory path for release packages
DIST_PATH ?= ./dist

# Number of seconds expected to complete container startup including bootstrap.
STARTUP_TIME ?= 2

# ------------------------------------------------------------------------------
# Application container configuration
# ------------------------------------------------------------------------------
MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER ?= true
MEMCACHED_CACHESIZE ?= 64
MEMCACHED_MAXCONN ?= 1024
MEMCACHED_OPTIONS ?= -U 0
