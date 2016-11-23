
# Common parameters of create and run targets
define DOCKER_CONTAINER_PARAMETERS
--name $(DOCKER_NAME) \
--restart $(DOCKER_RESTART_POLICY) \
--env "MEMCACHED_CACHESIZE=$(MEMCACHED_CACHESIZE)" \
--env "MEMCACHED_MAXCONN=$(MEMCACHED_MAXCONN)" \
--env "MEMCACHED_OPTIONS=$(MEMCACHED_OPTIONS)"
endef

DOCKER_PUBLISH := $(shell \
	if [[ $(DOCKER_PORT_MAP_TCP_11211) != NULL ]]; then printf -- '--publish %s:11211/tcp\n' $(DOCKER_PORT_MAP_TCP_11211); fi; \
	if [[ $(DOCKER_PORT_MAP_UDP_11211) != NULL ]]; then printf -- '--publish %s:11211/udp\n' $(DOCKER_PORT_MAP_UDP_11211); fi; \
)
