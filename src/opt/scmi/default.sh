
# Handle incrementing the docker host port for instances unless a port range is defined.
DOCKER_PUBLISH=
if [[ ${DOCKER_PORT_MAP_TCP_11211} != NULL ]]
then
	if grep -qE \
			'^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:)?[1-9][0-9]*$' \
			<<< "${DOCKER_PORT_MAP_TCP_11211}" \
		&& grep -qE \
			'^.+\.[0-9]+(\.[0-9]+)?$' \
			<<< "${DOCKER_NAME}"
	then
		printf -v \
			DOCKER_PUBLISH \
			-- '%s --publish %s%s:11211/tcp' \
			"${DOCKER_PUBLISH}" \
			"$(
				grep -o \
					'^[0-9\.]*:' \
					<<< "${DOCKER_PORT_MAP_TCP_11211}"
			)" \
			"$(( 
				$(
					grep -oE \
						'[0-9]+$' \
						<<< "${DOCKER_PORT_MAP_TCP_11211}"
				) \
				+ $(
					grep -oE \
						'([0-9]+)(\.[0-9]+)?$' \
						<<< "${DOCKER_NAME}" \
					| awk -F. \
						'{ print $1; }'
				) \
				- 1
			))"
	else
		printf -v \
			DOCKER_PUBLISH \
			-- '%s --publish %s:11211/tcp' \
			"${DOCKER_PUBLISH}" \
			"${DOCKER_PORT_MAP_TCP_11211}"
	fi
fi

if [[ ${DOCKER_PORT_MAP_UDP_11211} != NULL ]]
then
	if grep -qE \
			'^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:)?[1-9][0-9]*$' \
			<<< "${DOCKER_PORT_MAP_UDP_11211}" \
		&& grep -qE \
			'^.+\.[0-9]+(\.[0-9]+)?$' \
			<<< "${DOCKER_NAME}"
	then
		printf -v \
			DOCKER_PUBLISH \
			-- '%s --publish %s%s:11211/udp' \
			"${DOCKER_PUBLISH}" \
			"$(
				grep -o \
					'^[0-9\.]*:' \
					<<< "${DOCKER_PORT_MAP_UDP_11211}"
			)" \
			"$(( 
				$(
					grep -oE \
						'[0-9]+$' \
						<<< "${DOCKER_PORT_MAP_UDP_11211}"
				) \
				+ $(
					grep -oE \
						'([0-9]+)(\.[0-9]+)?$' \
						<<< "${DOCKER_NAME}" \
					| awk -F. \
						'{ print $1; }'
				) \
				- 1
			))"
	else
		printf -v \
			DOCKER_PUBLISH \
			-- '%s --publish %s:11211/udp' \
			"${DOCKER_PUBLISH}" \
			"${DOCKER_PORT_MAP_UDP_11211}"
	fi
fi

# Common parameters of create and run targets
DOCKER_CONTAINER_PARAMETERS="--name ${DOCKER_NAME} \
--restart ${DOCKER_RESTART_POLICY} \
--sysctl \"net.core.somaxconn=${SYSCTL_NET_CORE_SOMAXCONN}\" \
--sysctl \"net.ipv4.ip_local_port_range=${SYSCTL_NET_IPV4_IP_LOCAL_PORT_RANGE}\" \
--sysctl \"net.ipv4.route.flush=${SYSCTL_NET_IPV4_ROUTE_FLUSH}\" \
--env \"ENABLE_MEMCACHED_WRAPPER=${ENABLE_MEMCACHED_WRAPPER}\" \
--env \"MEMCACHED_CACHESIZE=${MEMCACHED_CACHESIZE}\" \
--env \"MEMCACHED_MAXCONN=${MEMCACHED_MAXCONN}\" \
--env \"MEMCACHED_OPTIONS=${MEMCACHED_OPTIONS}\" \
--env \"SYSTEM_TIMEZONE=${SYSTEM_TIMEZONE}\" \
${DOCKER_PUBLISH}"
