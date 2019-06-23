FROM jdeathe/centos-ssh:1.10.1

ARG RELEASE_VERSION="1.3.1"

# ------------------------------------------------------------------------------
# Base install of required packages
# ------------------------------------------------------------------------------
RUN rpm --rebuilddb \
	&& yum -y install \
			--setopt=tsflags=nodocs \
			--disableplugin=fastestmirror \
		libmemcached-0.31-1.1.el6 \
		memcached-1.4.4-5.el6 \
	&& yum versionlock add \
		libmemcached* \
		memcached* \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all

# ------------------------------------------------------------------------------
# Copy files into place
# ------------------------------------------------------------------------------
ADD src /

# ------------------------------------------------------------------------------
# Provisioning
# - Replace placeholders with values in systemd service unit template
# - Set permissions
# ------------------------------------------------------------------------------
RUN sed -i \
		-e "s~{{RELEASE_VERSION}}~${RELEASE_VERSION}~g" \
		/etc/systemd/system/centos-ssh-memcached@.service \
	&& chmod 644 \
		/etc/supervisord.d/memcached-wrapper.conf \
	&& chmod 700 \
		/usr/{bin/healthcheck,sbin/memcached-wrapper}

EXPOSE 11211

# ------------------------------------------------------------------------------
# Set default environment variables
# ------------------------------------------------------------------------------
ENV MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER="true" \
	MEMCACHED_CACHESIZE="64" \
	MEMCACHED_MAXCONN="1024" \
	MEMCACHED_OPTIONS="-U 0" \
	SSH_AUTOSTART_SSHD="false" \
	SSH_AUTOSTART_SSHD_BOOTSTRAP="false" \
	SSH_AUTOSTART_SUPERVISOR_STDOUT="false"

# ------------------------------------------------------------------------------
# Set image metadata
# ------------------------------------------------------------------------------
LABEL \
	maintainer="James Deathe <james.deathe@gmail.com>" \
	install="docker run \
--rm \
--privileged \
--volume /:/media/root \
jdeathe/centos-ssh-memcached:${RELEASE_VERSION} \
/usr/sbin/scmi install \
--chroot=/media/root \
--name=\${NAME} \
--tag=${RELEASE_VERSION}" \
	uninstall="docker run \
--rm \
--privileged \
--volume /:/media/root \
jdeathe/centos-ssh-memcached:${RELEASE_VERSION} \
/usr/sbin/scmi uninstall \
--chroot=/media/root \
--name=\${NAME} \
--tag=${RELEASE_VERSION}" \
	org.deathe.name="centos-ssh-memcached" \
	org.deathe.version="${RELEASE_VERSION}" \
	org.deathe.release="jdeathe/centos-ssh-memcached:${RELEASE_VERSION}" \
	org.deathe.license="MIT" \
	org.deathe.vendor="jdeathe" \
	org.deathe.url="https://github.com/jdeathe/centos-ssh-memcached" \
	org.deathe.description="Memcached 1.4 - CentOS-6 6.10 x86_64."

HEALTHCHECK \
	--interval=1s \
	--timeout=1s \
	--retries=4 \
	CMD ["/usr/bin/healthcheck"]

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]
