# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
readonly DOCKER_IMAGE_NAME=centos-ssh-memcached
readonly DOCKER_IMAGE_RELEASE_TAG_PATTERN='^[1-2]\.[0-9]+\.[0-9]+$'
readonly DOCKER_IMAGE_TAG_PATTERN='^(latest|[1-2]\.[0-9]+\.[0-9]+)$'
readonly DOCKER_USER=jdeathe

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
DIST_PATH="${DIST_PATH:-./dist}"
DOCKER_CONTAINER_OPTS="${DOCKER_CONTAINER_OPTS:-}"
DOCKER_IMAGE_TAG="${DOCKER_IMAGE_TAG:-latest}"
DOCKER_NAME="${DOCKER_NAME:-memcached.1}"
DOCKER_PORT_MAP_TCP_11211="${DOCKER_PORT_MAP_TCP_11211:-11211}"
DOCKER_PORT_MAP_UDP_11211="${DOCKER_PORT_MAP_UDP_11211:-NULL}"
DOCKER_RESTART_POLICY="${DOCKER_RESTART_POLICY:-always}"
NO_CACHE="${NO_CACHE:-false}"
REGISTER_ETCD_PARAMETERS="${REGISTER_ETCD_PARAMETERS:-}"
REGISTER_TTL="${REGISTER_TTL:-60}"
REGISTER_UPDATE_INTERVAL="${REGISTER_UPDATE_INTERVAL:-55}"
STARTUP_TIME="${STARTUP_TIME:-1}"
SYSCTL_NET_CORE_SOMAXCONN="${SYSCTL_NET_CORE_SOMAXCONN:-1024}"
SYSCTL_NET_IPV4_IP_LOCAL_PORT_RANGE="${SYSCTL_NET_IPV4_IP_LOCAL_PORT_RANGE:-1024 65535}"
SYSCTL_NET_IPV4_ROUTE_FLUSH="${SYSCTL_NET_IPV4_ROUTE_FLUSH:-1}"

# ------------------------------------------------------------------------------
# Application container configuration
# ------------------------------------------------------------------------------
ENABLE_MEMCACHED_WRAPPER="${ENABLE_MEMCACHED_WRAPPER:-true}"
MEMCACHED_CACHESIZE="${MEMCACHED_CACHESIZE:-64}"
MEMCACHED_MAXCONN="${MEMCACHED_MAXCONN:-1024}"
MEMCACHED_OPTIONS="${MEMCACHED_OPTIONS:-"-U 0"}"
SYSTEM_TIMEZONE="${SYSTEM_TIMEZONE:-UTC}"
