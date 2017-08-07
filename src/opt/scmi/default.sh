
# Handle incrementing the docker host port for instances unless a port range is defined.
DOCKER_PUBLISH=
if [[ ${DOCKER_PORT_MAP_TCP_11211} != NULL ]]; then
	if grep -qE '^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:)?[0-9]*$' <<< "${DOCKER_PORT_MAP_TCP_11211}" \
		&& grep -qE '^.+\.([0-9]+)\.([0-9]+)$' <<< "${DOCKER_NAME}"; then
		printf -v \
			DOCKER_PUBLISH \
			-- '%s --publish %s%s:11211/tcp' \
			"${DOCKER_PUBLISH}" \
			"$(grep -o '^[0-9\.]*:' <<< "${DOCKER_PORT_MAP_TCP_11211}")" \
			"$(( $(grep -o '[0-9]*$' <<< "${DOCKER_PORT_MAP_TCP_11211}") + $(sed 's~\.[0-9]*$~~' <<< "${DOCKER_NAME}" | awk -F. '{ print $NF; }') - 1 ))"
	else
		printf -v \
			DOCKER_PUBLISH \
			-- '%s --publish %s:11211/tcp' \
			"${DOCKER_PUBLISH}" \
			"${DOCKER_PORT_MAP_TCP_11211}"
	fi
fi

if [[ ${DOCKER_PORT_MAP_UDP_11211} != NULL ]]; then
	if grep -qE '^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:)?[0-9]*$' <<< "${DOCKER_PORT_MAP_UDP_11211}" \
		&& grep -qE '^.+\.([0-9]+)\.([0-9]+)$' <<< "${DOCKER_NAME}"; then
		printf -v \
			DOCKER_PUBLISH \
			-- '%s --publish %s%s:11211/udp' \
			"${DOCKER_PUBLISH}" \
			"$(grep -o '^[0-9\.]*:' <<< "${DOCKER_PORT_MAP_UDP_11211}")" \
			"$(( $(grep -o '[0-9]*$' <<< "${DOCKER_PORT_MAP_UDP_11211}") + $(sed 's~\.[0-9]*$~~' <<< "${DOCKER_NAME}" | awk -F. '{ print $NF; }') - 1 ))"
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
--env \"MEMCACHED_CACHESIZE=${MEMCACHED_CACHESIZE}\" \
--env \"MEMCACHED_MAXCONN=${MEMCACHED_MAXCONN}\" \
--env \"MEMCACHED_OPTIONS=${MEMCACHED_OPTIONS}\" \
${DOCKER_PUBLISH}"