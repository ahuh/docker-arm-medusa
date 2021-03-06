#! /bin/bash

MEDUSA_CONFIG_FILE=/config/config.ini
if [ ! -e "${MEDUSA_CONFIG_FILE}" ] ; then
	# Create config file if not exists
    touch ${MEDUSA_CONFIG_FILE}
    chown ${RUN_AS}:${RUN_AS} ${MEDUSA_CONFIG_FILE}
fi

# Add or update environment vars (tv shows dir, post processing dir, unrar tool, torrent client)
crudini --set $MEDUSA_CONFIG_FILE General root_dirs "0, /tvshowsdir"
crudini --set $MEDUSA_CONFIG_FILE General tv_download_dir "/postprocessingdir"
crudini --set $MEDUSA_CONFIG_FILE General unrar_tool unrar
crudini --set $MEDUSA_CONFIG_FILE General use_torrents 1
crudini --set $MEDUSA_CONFIG_FILE General torrent_method ${TORRENT_MODE}
crudini --set $MEDUSA_CONFIG_FILE General process_automatically 1
crudini --set $MEDUSA_CONFIG_FILE General handle_reverse_proxy 1
crudini --set $MEDUSA_CONFIG_FILE TORRENT torrent_auth_type none
crudini --set $MEDUSA_CONFIG_FILE TORRENT torrent_host "http://dockerhost:${TORRENT_PORT}/"
if [ "${TORRENT_MODE}" = "transmission" ]; then
	# Transmission: the destination dir must exist in the Transmission Docker Container
	crudini --set $MEDUSA_CONFIG_FILE TORRENT torrent_path "/downloaddir/${TORRENT_LABEL}"
	crudini --del $MEDUSA_CONFIG_FILE TORRENT torrent_label
fi
if [ "${TORRENT_MODE}" = "qbittorrent" ]; then
	# qBittorrent: no label supported by version package with raspbian 'jessie'
	crudini --del $MEDUSA_CONFIG_FILE TORRENT torrent_label
	crudini --del $MEDUSA_CONFIG_FILE TORRENT torrent_path
fi
if [[ ${PROXY_PORT} ]]; then
	crudini --set $MEDUSA_CONFIG_FILE General proxy_setting "http://dockerhost:${PROXY_PORT}"
	crudini --set $MEDUSA_CONFIG_FILE General proxy_indexers 1
else
	crudini --del $MEDUSA_CONFIG_FILE General proxy_setting
fi

export MEDUSA_CONFIG_FILE