readonly STARTUP_TIME=1
readonly TEST_DIRECTORY="test"

# These should ideally be a static value but hosts might be using this port so 
# need to allow for alternatives.
DOCKER_PORT_MAP_TCP_22="${DOCKER_PORT_MAP_TCP_22:-NULL}"
DOCKER_PORT_MAP_TCP_11211="${DOCKER_PORT_MAP_TCP_11211:-11211}"

function __destroy ()
{
	:
}

function __get_container_port ()
{
	local container="${1:-}"
	local port="${2:-}"
	local value=""

	value="$(
		docker port \
			${container} \
			${port}
	)"
	value=${value##*:}

	printf -- \
		'%s' \
		"${value}"
}

# container - Docker container name.
# counter - Timeout counter in seconds.
# process_pattern - Regular expression pattern used to match running process.
# ready_test - Command used to test if the service is ready.
function __is_container_ready ()
{
	local container="${1:-}"
	local counter=$(
		awk \
			-v seconds="${2:-10}" \
			'BEGIN { print 10 * seconds; }'
	)
	local process_pattern="${3:-}"
	local ready_test="${4:-true}"

	until (( counter == 0 )); do
		sleep 0.1

		if docker exec ${container} \
			bash -c "ps axo command \
				| grep -qE \"${process_pattern}\" \
				&& eval \"${ready_test}\"" \
			&> /dev/null
		then
			break
		fi

		(( counter -= 1 ))
	done

	if (( counter == 0 )); then
		return 1
	fi

	return 0
}

function __setup ()
{
	:
}

# Custom shpec matcher
# Match a string with an Extended Regular Expression pattern.
function __shpec_matcher_egrep ()
{
	local pattern="${2:-}"
	local string="${1:-}"

	printf -- \
		'%s' \
		"${string}" \
	| grep -qE -- \
		"${pattern}" \
		-

	assert equal \
		"${?}" \
		0
}

function __terminate_container ()
{
	local container="${1}"

	if docker ps -aq \
		--filter "name=${container}" \
		--filter "status=paused" &> /dev/null; then
		docker unpause ${container} &> /dev/null
	fi

	if docker ps -aq \
		--filter "name=${container}" \
		--filter "status=running" &> /dev/null; then
		docker stop ${container} &> /dev/null
	fi

	if docker ps -aq \
		--filter "name=${container}" &> /dev/null; then
		docker rm -vf ${container} &> /dev/null
	fi
}

function test_basic_operations ()
{
	local container_port_11211=""
	local maxbytes_value=""
	local maxconns_value=""
	local udpport_value=""

	trap "__terminate_container memcached.pool-1.1.1 &> /dev/null; \
		__destroy; \
		exit 1" \
		INT TERM EXIT

	describe "Basic Memcached operations"
		__terminate_container \
			memcached.pool-1.1.1 \
		&> /dev/null

		it "Runs a Memcached container named memcached.pool-1.1.1 on port ${DOCKER_PORT_MAP_TCP_11211}."
			docker run \
				--detach \
				--name memcached.pool-1.1.1 \
				--publish ${DOCKER_PORT_MAP_TCP_11211}:11211 \
				jdeathe/centos-ssh-memcached:latest \
			&> /dev/null

			container_port_11211="$(
				__get_container_port \
					memcached.pool-1.1.1 \
					11211/tcp
			)"

			if [[ ${DOCKER_PORT_MAP_TCP_11211} == 0 ]] \
				|| [[ -z ${DOCKER_PORT_MAP_TCP_11211} ]]; then
				assert gt \
					"${container_port_11211}" \
					"30000"
			else
				assert equal \
					"${container_port_11211}" \
					"${DOCKER_PORT_MAP_TCP_11211}"
			fi
		end

		if ! __is_container_ready \
			memcached.pool-1.1.1 \
			${STARTUP_TIME} \
			"/usr/bin/memcached " \
			"memcached-tool \
				127.0.0.1:11211 \
				stats \
			| grep -qP \
				'[ ]+accepting_conns[ ]+1[^0-9]*$'"
		then
			exit 1
		fi

		it "Responds to the Memcached stats command."
			expect test/telnet-memcached.exp \
				127.0.0.1 \
				${container_port_11211} \
				"stats" \
			| grep -qE '^STAT uptime [0-9]+'

			assert equal \
				"${?}" \
				0
		end

		it "Defaults to a maxbytes setting of 64M."
			maxbytes_value="$(
				expect test/telnet-memcached.exp \
					127.0.0.1 \
					${container_port_11211} \
					"stats settings" \
				| grep -E '^STAT maxbytes [0-9]+' \
				| awk '{ print $3; }' \
				| tr -d '\r'
			)"

			assert equal \
				"${maxbytes_value}" \
				67108864
		end

		it "Defaults to a maxconns setting of 1024."
			maxconns_value="$(
				expect test/telnet-memcached.exp \
					127.0.0.1 \
					${container_port_11211} \
					"stats settings" \
				| grep -E '^STAT maxconns [0-9]+' \
				| awk '{ print $3; }' \
				| tr -d '\r'
			)"

			assert equal \
				"${maxconns_value}" \
				1024
		end

		it "Defaults to TCP only (i.e udpport setting of 0)."
			udpport_value="$(
				expect test/telnet-memcached.exp \
					127.0.0.1 \
					${container_port_11211} \
					"stats settings" \
				| grep -E '^STAT udpport [0-9]+' \
				| awk '{ print $3; }' \
				| tr -d '\r'
			)"

			assert equal \
				"${udpport_value}" \
				0
		end

		__terminate_container \
			memcached.pool-1.1.1 \
		&> /dev/null
	end

	trap - \
		INT TERM EXIT
}

function test_custom_configuration ()
{
	local container_port_11211=""
	local item_size_max_value=""
	local maxbytes_value=""
	local maxconns_value=""
	local udpport_value=""

	trap "__terminate_container memcached.pool-1.1.1 &> /dev/null; \
		__destroy; \
		exit 1" \
		INT TERM EXIT

	describe "Customised Memcached configuration"
		__terminate_container \
			memcached.pool-1.1.1 \
		&> /dev/null

		it "Runs a Memcached container named memcached.pool-1.1.1 on port ${DOCKER_PORT_MAP_TCP_11211}."
			docker run \
				--detach \
				--name memcached.pool-1.1.1 \
				--publish ${DOCKER_PORT_MAP_TCP_11211}:11211 \
				--env "MEMCACHED_CACHESIZE=32" \
				--env "MEMCACHED_MAXCONN=2048" \
				--env "MEMCACHED_OPTIONS=-U 0 -I 8M" \
				jdeathe/centos-ssh-memcached:latest \
			&> /dev/null

			container_port_11211="$(
				__get_container_port \
					memcached.pool-1.1.1 \
					11211/tcp
			)"

			if [[ ${DOCKER_PORT_MAP_TCP_11211} == 0 ]] \
				|| [[ -z ${DOCKER_PORT_MAP_TCP_11211} ]]; then
				assert gt \
					"${container_port_11211}" \
					"30000"
			else
				assert equal \
					"${container_port_11211}" \
					"${DOCKER_PORT_MAP_TCP_11211}"
			fi
		end

		if ! __is_container_ready \
			memcached.pool-1.1.1 \
			${STARTUP_TIME} \
			"/usr/bin/memcached " \
			"memcached-tool \
				127.0.0.1:11211 \
				stats \
			| grep -qP \
				'[ ]+accepting_conns[ ]+1[^0-9]*$'"
		then
			exit 1
		fi

		it "Responds to the Memcached stats command."
			expect test/telnet-memcached.exp \
				127.0.0.1 \
				${container_port_11211} \
				"stats" \
			| grep -qE '^STAT uptime [0-9]+'

			assert equal \
				"${?}" \
				0
		end

		it "Runs with a maxbytes setting of 32M."
			maxbytes_value="$(
				expect test/telnet-memcached.exp \
					127.0.0.1 \
					${container_port_11211} \
					"stats settings" \
				| grep -E '^STAT maxbytes [0-9]+' \
				| awk '{ print $3; }' \
				| tr -d '\r'
			)"

			assert equal \
				"${maxbytes_value}" \
				33554432
		end

		it "Runs with a maxconns setting of 2048."
			maxconns_value="$(
				expect test/telnet-memcached.exp \
					127.0.0.1 \
					${container_port_11211} \
					"stats settings" \
				| grep -E '^STAT maxconns [0-9]+' \
				| awk '{ print $3; }' \
				| tr -d '\r'
			)"

			assert equal \
				"${maxconns_value}" \
				2048
		end

		it "Runs with UDP off (i.e udpport setting of 0)."
			udpport_value="$(
				expect test/telnet-memcached.exp \
					127.0.0.1 \
					${container_port_11211} \
					"stats settings" \
				| grep -E '^STAT udpport [0-9]+' \
				| awk '{ print $3; }' \
				| tr -d '\r'
			)"

			assert equal \
				"${udpport_value}" \
				0

				it "Adjusts max item size to 8M (i.e > 1M default)."
					item_size_max_value="$(
						expect test/telnet-memcached.exp \
							127.0.0.1 \
							${container_port_11211} \
							"stats settings" \
						| grep -E '^STAT item_size_max [0-9]+' \
						| awk '{ print $3; }' \
						| tr -d '\r'
					)"

					assert equal \
						"${item_size_max_value}" \
						8388608
				end
		end

		__terminate_container \
			memcached.pool-1.1.1 \
		&> /dev/null
	end

	trap - \
		INT TERM EXIT
}

if [[ ! -d ${TEST_DIRECTORY} ]]; then
	printf -- \
		"ERROR: Please run from the project root.\n" \
		>&2
	exit 1
fi

describe "jdeathe/centos-ssh-memcached:latest"
	__destroy
	__setup
	test_basic_operations
	test_custom_configuration
	__destroy
end
