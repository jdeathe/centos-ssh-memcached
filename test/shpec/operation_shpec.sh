readonly STARTUP_TIME=2
readonly TEST_DIRECTORY="test"

# These should ideally be a static value but hosts might be using this port so 
# need to allow for alternatives.
DOCKER_PORT_MAP_TCP_11211="${DOCKER_PORT_MAP_TCP_11211:-11211}"

function __destroy ()
{
	local -r private_network_1="bridge_internal_1"

	if [[ -n $(docker network ls -q -f name="${private_network_1}") ]]; then
		docker network rm \
			${private_network_1} \
		&> /dev/null
	fi
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
	local -r private_network_1="bridge_internal_1"

	if [[ -z $(docker network ls -q -f name="${private_network_1}") ]]; then
		docker network create \
			--internal \
			--driver bridge \
			--gateway 172.172.40.1 \
			--subnet 172.172.40.0/24 \
			${private_network_1} \
		&> /dev/null
	fi
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
	local settings_value=""

	trap "__terminate_container memcached.1 &> /dev/null; \
		__destroy; \
		exit 1" \
		INT TERM EXIT

	describe "Basic Memcached operations"
		describe "Runs named container"
			__terminate_container \
				memcached.1 \
			&> /dev/null

			it "Can publish ${DOCKER_PORT_MAP_TCP_11211}:11211."
				docker run \
					--detach \
					--name memcached.1 \
					--publish ${DOCKER_PORT_MAP_TCP_11211}:11211 \
					jdeathe/centos-ssh-memcached:latest \
				&> /dev/null

				container_port_11211="$(
					__get_container_port \
						memcached.1 \
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
		end

		if ! __is_container_ready \
			memcached.1 \
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

		describe "Default initialisation"
			it "Sets maxbytes=67108864."
				settings_value="$(
					expect test/telnet-memcached.exp \
						127.0.0.1 \
						${container_port_11211} \
						"stats settings" \
					| grep -E '^STAT maxbytes [0-9]+' \
					| awk '{ print $3; }' \
					| tr -d '\r'
				)"

				assert equal \
					"${settings_value}" \
					67108864
			end

			it "Sets maxconns=1024."
				settings_value="$(
					expect test/telnet-memcached.exp \
						127.0.0.1 \
						${container_port_11211} \
						"stats settings" \
					| grep -E '^STAT maxconns [0-9]+' \
					| awk '{ print $3; }' \
					| tr -d '\r'
				)"

				assert equal \
					"${settings_value}" \
					1024
			end

			it "Sets udpport=0."
				settings_value="$(
					expect test/telnet-memcached.exp \
						127.0.0.1 \
						${container_port_11211} \
						"stats settings" \
					| grep -E '^STAT udpport [0-9]+' \
					| awk '{ print $3; }' \
					| tr -d '\r'
				)"

				assert equal \
					"${settings_value}" \
					0
			end
		end

		__terminate_container \
			memcached.1 \
		&> /dev/null
	end

	trap - \
		INT TERM EXIT
}

function test_custom_configuration ()
{
	local -r private_network_1="bridge_internal_1"
	local -r test_data_input="$(< test/fixtures/lorem-ipsum-base64.txt)"
	local container_port_11211=""
	local settings_value=""
	local test_data_output=""

	trap "__terminate_container memcached.1 &> /dev/null; \
		__terminate_container memcached.2 &> /dev/null; \
		__destroy; \
		exit 1" \
		INT TERM EXIT

	describe "Customised Memcached configuration"
		describe "Runs named container"
			__terminate_container \
				memcached.1 \
			&> /dev/null

			it "Can publish ${DOCKER_PORT_MAP_TCP_11211}:11211."
				docker run \
					--detach \
					--name memcached.1 \
					--publish ${DOCKER_PORT_MAP_TCP_11211}:11211 \
					--env "MEMCACHED_CACHESIZE=32" \
					--env "MEMCACHED_MAXCONN=2048" \
					--env "MEMCACHED_OPTIONS=-U 0 -I 2M" \
					jdeathe/centos-ssh-memcached:latest \
				&> /dev/null

				container_port_11211="$(
					__get_container_port \
						memcached.1 \
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
		end

		if ! __is_container_ready \
			memcached.1 \
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

		describe "Custom initialisation"
			it "Sets maxbytes=33554432."
				settings_value="$(
					expect test/telnet-memcached.exp \
						127.0.0.1 \
						${container_port_11211} \
						"stats settings" \
					| grep -E '^STAT maxbytes [0-9]+' \
					| awk '{ print $3; }' \
					| tr -d '\r'
				)"

				assert equal \
					"${settings_value}" \
					33554432
			end

			it "Sets maxconns=2048."
				settings_value="$(
					expect test/telnet-memcached.exp \
						127.0.0.1 \
						${container_port_11211} \
						"stats settings" \
					| grep -E '^STAT maxconns [0-9]+' \
					| awk '{ print $3; }' \
					| tr -d '\r'
				)"

				assert equal \
					"${settings_value}" \
					2048
			end

			it "Sets udpport=0."
				settings_value="$(
					expect test/telnet-memcached.exp \
						127.0.0.1 \
						${container_port_11211} \
						"stats settings" \
					| grep -E '^STAT udpport [0-9]+' \
					| awk '{ print $3; }' \
					| tr -d '\r'
				)"

				assert equal \
					"${settings_value}" \
					0
			end

			it "Sets item_size_max=2097152."
				settings_value="$(
					expect test/telnet-memcached.exp \
						127.0.0.1 \
						${container_port_11211} \
						"stats settings" \
					| grep -E '^STAT item_size_max [0-9]+' \
					| awk '{ print $3; }' \
					| tr -d '\r'
				)"

				assert equal \
					"${settings_value}" \
					2097152
			end
		end

		describe "Runs on a private network."
			__terminate_container \
				memcached.1 \
			&> /dev/null

			__terminate_container \
				memcached.2 \
			&> /dev/null

			it "Runs a named server container"
				docker run \
					--detach \
					--name memcached.1 \
					--network-alias memcached.1 \
					--network ${private_network_1} \
					jdeathe/centos-ssh-memcached:latest \
				&> /dev/null

				assert equal \
					"${?}" \
					0
			end

			it "Runs a named client container"
				docker run \
					--detach \
					--name memcached.2 \
					--network-alias memcached.2 \
					--network ${private_network_1} \
					--env MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER=false \
					jdeathe/centos-ssh-memcached:latest \
				&> /dev/null

				assert equal \
					"${?}" \
					0
			end

			if ! __is_container_ready \
				memcached.1 \
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

			if ! __is_container_ready \
				memcached.2 \
				${STARTUP_TIME} \
				"/usr/bin/memcached "
			then
				exit 1
			fi

			describe "Memcached usage"
				it "Can set data"
					docker cp \
						test/fixtures/lorem-ipsum-base64.txt \
						memcached.2:/tmp/lorem-ipsum-base64.txt

					docker exec \
						memcached.2 \
							memcp \
							--servers=memcached.1:11211 \
							/tmp/lorem-ipsum-base64.txt
					&> /dev/null

					assert equal \
						"${?}" \
						0
				end

				it "Can get data"
					# memcat appends a trailing newline if there's a line break.
					test_data_output="$(
						docker exec \
							memcached.2 \
							bash -c "memcat \
								--servers=memcached.1:11211 \
								lorem-ipsum-base64.txt \
							| awk 'NR > 1 { print line; } \
								{ line = \$0; } \
								END { printf \$0; }'"
					)"

					assert equal \
						"${test_data_output}" \
						"${test_data_input}"
				end

				it "Can flush data"
					docker exec \
						memcached.2 \
						memflush \
							--servers=memcached.1:11211

					test_data_output="$(
						docker exec \
							memcached.2 \
							bash -c "memcat \
								--servers=memcached.1:11211 \
								lorem-ipsum-base64.txt \
							2> /dev/null \
							| awk 'NR > 1 { print line; } \
								{ line = \$0; } \
								END { printf \$0; }'"
					)"

					assert equal \
						"${test_data_output}" \
						""
				end
			end
		end

		__terminate_container \
			memcached.1 \
		&> /dev/null

		__terminate_container \
			memcached.2 \
		&> /dev/null
	end

	describe "Configure autostart"
		__terminate_container \
			memcached.1 \
		&> /dev/null

		docker run \
			--detach \
			--name memcached.1 \
			--env MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER=false \
			jdeathe/centos-ssh-memcached:latest \
		&> /dev/null

		sleep ${STARTUP_TIME}

		it "Can disable memcached-wrapper."
			docker ps \
				--filter "name=memcached.1" \
				--filter "health=healthy" \
			&> /dev/null \
			&& docker top \
				memcached.1 \
			| grep -qE '/usr/bin/memcached '

			assert equal \
				"${?}" \
				"1"
		end

		__terminate_container \
			memcached.1 \
		&> /dev/null
	end

	trap - \
		INT TERM EXIT
}

function test_healthcheck ()
{
	local -r event_lag_seconds=2
	local -r interval_seconds=1
	local -r retries=4
	local events_since_timestamp
	local health_status

	trap "__terminate_container memcached.1 &> /dev/null; \
		__destroy; \
		exit 1" \
		INT TERM EXIT

	describe "Healthcheck"
		describe "Default configuration"
			__terminate_container \
				memcached.1 \
			&> /dev/null

			docker run \
				--detach \
				--name memcached.1 \
				jdeathe/centos-ssh-memcached:latest \
			&> /dev/null

			events_since_timestamp="$(
				date +%s
			)"

			it "Returns a valid status on starting."
				health_status="$(
					docker inspect \
						--format='{{json .State.Health.Status}}' \
						memcached.1
				)"

				assert __shpec_matcher_egrep \
					"${health_status}" \
					"\"(starting|healthy|unhealthy)\""
			end

			it "Returns healthy after startup."
				events_timeout="$(
					awk \
						-v event_lag="${event_lag_seconds}" \
						-v interval="${interval_seconds}" \
						-v startup_time="${STARTUP_TIME}" \
						'BEGIN { print event_lag + startup_time + interval; }'
				)"

				health_status="$(
					test/health_status \
						--container=memcached.1 \
						--since="${events_since_timestamp}" \
						--timeout="${events_timeout}" \
						--monochrome \
					2>&1
				)"

				assert equal \
					"${health_status}" \
					"✓ healthy"
			end

			it "Returns unhealthy on failure."
				# wrapper failure
				docker exec -t \
					memcached.1 \
					bash -c "mv \
						/usr/bin/memcached \
						/usr/bin/memcached2" \
				&& docker exec -t \
					memcached.1 \
					bash -c "if [[ -n \$(pgrep -f '^/usr/bin/memcached ') ]]; then \
						kill -9 \$(pgrep -f '^/usr/bin/memcached ')
					fi"

				events_since_timestamp="$(
					date +%s
				)"

				events_timeout="$(
					awk \
						-v event_lag="${event_lag_seconds}" \
						-v interval="${interval_seconds}" \
						-v retries="${retries}" \
						'BEGIN { print event_lag + (interval * retries); }'
				)"

				health_status="$(
					test/health_status \
						--container=memcached.1 \
						--since="$(( ${event_lag_seconds} + ${events_since_timestamp} ))" \
						--timeout="${events_timeout}" \
						--monochrome \
					2>&1
				)"

				assert equal \
					"${health_status}" \
					"✗ unhealthy"
			end

			__terminate_container \
				memcached.1 \
			&> /dev/null
		end
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
	test_healthcheck
	__destroy
end
