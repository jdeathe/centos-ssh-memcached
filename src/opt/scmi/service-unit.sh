# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
readonly SERVICE_UNIT_ENVIRONMENT_KEYS="
 DOCKER_CONTAINER_OPTS
 DOCKER_IMAGE_PACKAGE_PATH
 DOCKER_IMAGE_TAG
 DOCKER_PORT_MAP_TCP_11211
 DOCKER_PORT_MAP_UDP_11211
 MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER
 MEMCACHED_CACHESIZE
 MEMCACHED_MAXCONN
 MEMCACHED_OPTIONS
 SYSCTL_NET_CORE_SOMAXCONN
 SYSCTL_NET_IPV4_IP_LOCAL_PORT_RANGE
 SYSCTL_NET_IPV4_ROUTE_FLUSH
"
readonly SERVICE_UNIT_REGISTER_ENVIRONMENT_KEYS="
 REGISTER_ETCD_PARAMETERS
 REGISTER_TTL
 REGISTER_UPDATE_INTERVAL
"

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
SERVICE_UNIT_INSTALL_TIMEOUT="${SERVICE_UNIT_INSTALL_TIMEOUT:-5}"
