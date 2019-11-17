# Medusa
#
# Version 1.0

FROM balenalib/rpi-raspbian:buster
LABEL maintainer "ahuh"

# Volume config: contains Medusa config.ini (generated at first start if needed)
VOLUME /config
# Volume data: contains Medusa database, config, cache and log files
VOLUME /data
# Volume tvshowsdir: root directory containing tv shows files
# WARNING: must have read/write accept for execution user (PUID/PGID)
VOLUME /tvshowsdir
# Volume postprocessingdir: contains downloaded files, ready to by post-processed by Medusa
# WARNING: must have read/write accept for execution user (PUID/PGID)
VOLUME /postprocessingdir
# Volume userhome: home directory for execution user
VOLUME /userhome

# Set environment variables
# - Set torrent mode (transmission or qbittorrent), label and port, and execution user (PUID/PGID)
ENV AUTO_UPDATE=\
	TORRENT_MODE=\
	TORRENT_PORT=\
	TORRENT_LABEL=\
	PUID=\
    PGID=
# - Set xterm for nano
ENV TERM xterm

# Copy custom bashrc to root (ll aliases)
COPY root/ /root/
# Copy unrar bin to root tmp
COPY unrar/ /root/tmp/

# Update packages and install software
RUN apt-get update \
	&& apt-get install -y curl wget gzip nano crudini \
	&& apt-get install -y mediainfo \
	&& apt-get install -y python3 \
	&& apt-get install -y dumb-init \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install unrar
RUN gzip -d /root/tmp/unrar-5.5.0-arm.gz \
    && mv /root/tmp/unrar-5.5.0-arm /usr/bin/unrar \
    && chmod 755 /usr/bin/unrar \
    && rm -rf /root/tmp

# Download and manually install medusa
RUN mkdir -p /opt/medusa \
	&& mkdir -p /etc/medusa \
 	&& export MEDUSA_VERSION=$(curl -k -sX GET "https://api.github.com/repos/pymedusa/Medusa/releases/latest" | tac | awk '/tag_name/{print $4;exit}' FS='[""]') \
	&& echo $MEDUSA_VERSION > /etc/medusa/medusa_version \
	&& curl -k -o /tmp/medusa.tar.gz -L "https://github.com/pymedusa/Medusa/archive/${MEDUSA_VERSION}.tar.gz" \
	&& tar xf /tmp/medusa.tar.gz -C /opt/medusa --strip-components=1

# Create and set user & group for impersonation
RUN groupmod -g 1000 users \
    && useradd -u 911 -U -d /userhome -s /bin/false abc \
    && usermod -G users abc
	
# Copy scripts
COPY medusa/ /etc/medusa/

# Make scripts executable
RUN chmod +x /etc/medusa/*.sh

# Expose port
EXPOSE 8081

# Launch Medusa at container start
CMD ["dumb-init", "/etc/medusa/start.sh"]
