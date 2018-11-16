
# Common parameters of create and run targets
define DOCKER_CONTAINER_PARAMETERS
--name $(DOCKER_NAME) \
--restart $(DOCKER_RESTART_POLICY) \
--sysctl "net.core.somaxconn=$(SYSCTL_NET_CORE_SOMAXCONN)" \
--sysctl "net.ipv4.ip_local_port_range=$(SYSCTL_NET_IPV4_IP_LOCAL_PORT_RANGE)" \
--sysctl "net.ipv4.route.flush=$(SYSCTL_NET_IPV4_ROUTE_FLUSH)" \
--env "MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER=$(MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER)" \
--env "MEMCACHED_CACHESIZE=$(MEMCACHED_CACHESIZE)" \
--env "MEMCACHED_MAXCONN=$(MEMCACHED_MAXCONN)" \
--env "MEMCACHED_OPTIONS=$(MEMCACHED_OPTIONS)"
endef

DOCKER_PUBLISH := $(shell \
	if [[ $(DOCKER_PORT_MAP_TCP_11211) != NULL ]]; then printf -- '--publish %s:11211/tcp\n' $(DOCKER_PORT_MAP_TCP_11211); fi; \
	if [[ $(DOCKER_PORT_MAP_UDP_11211) != NULL ]]; then printf -- '--publish %s:11211/udp\n' $(DOCKER_PORT_MAP_UDP_11211); fi; \
)
