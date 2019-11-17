#! /bin/bash

. /etc/medusa/updateMedusa.sh

. /etc/medusa/userSetup.sh

echo "PREPARING MEDUSA CONFIG"
. /etc/medusa/prepareConfig.sh

echo "STARTING MEDUSA"
sudo -u ${RUN_AS} python3 /opt/medusa/start.py --config=${MEDUSA_CONFIG_FILE} --datadir=/data/