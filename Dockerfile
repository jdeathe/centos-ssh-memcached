# =============================================================================
# jdeathe/centos-ssh-memcached
#
# CentOS-6, Memcached 1.4.
# =============================================================================
FROM jdeathe/centos-ssh:centos-6-1.7.3

MAINTAINER James Deathe <james.deathe@gmail.com>

RUN rpm --rebuilddb \
	&& yum --setopt=tsflags=nodocs -y install \
		memcached-1.4.4-3.el6 \
	&& yum versionlock add \
		memcached* \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all

# -----------------------------------------------------------------------------
# Copy files into place
# -----------------------------------------------------------------------------
ADD usr/sbin/memcached-wrapper \
	/usr/sbin/
ADD opt/scmi \
	/opt/scmi/
ADD etc/services-config/supervisor/supervisord.d \
	/etc/services-config/supervisor/supervisord.d/
ADD etc/systemd/system \
	/etc/systemd/system/

RUN ln -sf \
		/etc/services-config/supervisor/supervisord.d/memcached-wrapper.conf \
		/etc/supervisord.d/memcached-wrapper.conf \
	&& chmod 700 \
		/usr/sbin/memcached-wrapper

EXPOSE 11211

# -----------------------------------------------------------------------------
# Set default environment variables
# -----------------------------------------------------------------------------
ENV MEMCACHED_CACHESIZE="64" \
	MEMCACHED_MAXCONN="1024" \
	MEMCACHED_OPTIONS="-U 0" \
	SSH_AUTOSTART_SSHD=false \
	SSH_AUTOSTART_SSHD_BOOTSTRAP=false

# -----------------------------------------------------------------------------
# Set image metadata
# -----------------------------------------------------------------------------
ARG RELEASE_VERSION="1.0.0"
LABEL \
	install="docker run \
--rm \
--privileged \
--volume /:/media/root \
jdeathe/centos-ssh-memcached:centos-6-${RELEASE_VERSION} \
/usr/sbin/scmi install \
--chroot=/media/root \
--name=\${NAME} \
--tag=centos-6-${RELEASE_VERSION}" \
	uninstall="docker run \
--rm \
--privileged \
--volume /:/media/root \
jdeathe/centos-ssh-memcached:centos-6-${RELEASE_VERSION} \
/usr/sbin/scmi uninstall \
--chroot=/media/root \
--name=\${NAME} \
--tag=centos-6-${RELEASE_VERSION}" \
	org.deathe.name="centos-ssh-memcached" \
	org.deathe.version="${RELEASE_VERSION}" \
	org.deathe.release="jdeathe/centos-ssh-memcached:centos-6-${RELEASE_VERSION}" \
	org.deathe.license="MIT" \
	org.deathe.vendor="jdeathe" \
	org.deathe.url="https://github.com/jdeathe/centos-ssh-memcached" \
	org.deathe.description="CentOS-6 6.8 x86_64 - Memcached 1.4."

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]