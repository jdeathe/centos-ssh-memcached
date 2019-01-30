FROM jdeathe/centos-ssh:2.5.0

ARG RELEASE_VERSION="2.1.1"

# -----------------------------------------------------------------------------
# Base install of required packages
# -----------------------------------------------------------------------------
RUN rpm --rebuilddb \
	&& yum -y install \
			--setopt=tsflags=nodocs \
			--disableplugin=fastestmirror \
		libmemcached-1.0.16-5.el7 \
		memcached-1.4.15-10.el7_3.1 \
	&& yum versionlock add \
		libmemcached* \
		memcached* \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all

# -----------------------------------------------------------------------------
# Copy files into place
# -----------------------------------------------------------------------------
ADD src/usr/bin \
	/usr/bin/
ADD src/usr/sbin \
	/usr/sbin/
ADD src/opt/scmi \
	/opt/scmi/
ADD src/etc/services-config/supervisor/supervisord.d \
	/etc/services-config/supervisor/supervisord.d/
ADD src/etc/systemd/system \
	/etc/systemd/system/

# -----------------------------------------------------------------------------
# Provisioning
# - Set permissions
# -----------------------------------------------------------------------------
RUN ln -sf \
		/etc/services-config/supervisor/supervisord.d/memcached-wrapper.conf \
		/etc/supervisord.d/memcached-wrapper.conf \
	&& chmod 700 \
		/usr/{bin/healthcheck,sbin/memcached-wrapper}

EXPOSE 11211

# -----------------------------------------------------------------------------
# Set default environment variables
# -----------------------------------------------------------------------------
ENV MEMCACHED_AUTOSTART_MEMCACHED_WRAPPER=true \
	MEMCACHED_CACHESIZE="64" \
	MEMCACHED_MAXCONN="1024" \
	MEMCACHED_OPTIONS="-U 0" \
	SSH_AUTOSTART_SSHD=false \
	SSH_AUTOSTART_SSHD_BOOTSTRAP=false

# -----------------------------------------------------------------------------
# Set image metadata
# -----------------------------------------------------------------------------
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
	org.deathe.description="CentOS-7 7.5.1804 x86_64 - Memcached 1.4."

HEALTHCHECK \
	--interval=0.5s \
	--timeout=1s \
	--retries=4 \
	CMD ["/usr/bin/healthcheck"]

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]