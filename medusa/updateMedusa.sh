#! /bin/bash

MEDUSA_UPDATED_FILE=/etc/medusa/updated

if [ "${AUTO_UPDATE}" = true ] && [ ! -e "${MEDUSA_UPDATED_FILE}" ] ; then
	# First start of the docker container with AUTO_UPDATE env enabled: update Medusa from GitHub
	echo "UPDATE MEDUSA"
	
	rm -rf /opt/medusa
	mkdir -p /opt/medusa

	# Download and manually install medusa
 	export MEDUSA_VERSION=$(curl -k -sX GET "https://api.github.com/repos/pymedusa/Medusa/releases/latest" | jq -r .tag_name)
	echo $MEDUSA_VERSION > /etc/medusa/medusa_version
	curl -k -o /tmp/medusa.tar.gz -sSL "https://github.com/pymedusa/Medusa/archive/${MEDUSA_VERSION}.tar.gz"
	tar xvfz /tmp/medusa.tar.gz -C /opt/medusa --strip-components=1
	
	touch ${MEDUSA_UPDATED_FILE}
fi
