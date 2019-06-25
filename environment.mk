# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
DOCKER_IMAGE_NAME := centos-ssh-memcached
DOCKER_IMAGE_RELEASE_TAG_PATTERN := ^[1-2]\.[0-9]+\.[0-9]+$
DOCKER_IMAGE_TAG_PATTERN := ^(latest|[1-2]\.[0-9]+\.[0-9]+)$
DOCKER_USER := jdeathe
SHPEC_ROOT := test/shpec

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
DIST_PATH ?= ./dist
DOCKER_CONTAINER_OPTS ?=
DOCKER_IMAGE_TAG ?= latest
DOCKER_NAME ?= memcached.1
DOCKER_PORT_MAP_TCP_11211 ?= 11211
DOCKER_PORT_MAP_UDP_11211 ?= NULL
DOCKER_RESTART_POLICY ?= always
NO_CACHE ?= false
RELOAD_SIGNAL ?= HUP
STARTUP_TIME ?= 1
SYSCTL_NET_CORE_SOMAXCONN ?= 1024
SYSCTL_NET_IPV4_IP_LOCAL_PORT_RANGE ?= 1024 65535
SYSCTL_NET_IPV4_ROUTE_FLUSH ?= 1

# ------------------------------------------------------------------------------
# Application container configuration
# ------------------------------------------------------------------------------
ENABLE_MEMCACHED_WRAPPER ?= true
MEMCACHED_CACHESIZE ?= 64
MEMCACHED_MAXCONN ?= 1024
MEMCACHED_OPTIONS ?= -U 0
SYSTEM_TIMEZONE ?= UTC
