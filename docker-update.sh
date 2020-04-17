#!/bin/sh

echo "Stopping docker container ..."
docker stop medusa
echo "Removing docker container ..."
docker rm medusa
echo "Stopping docker daemon ..."
/usr/sbin/docker_daemon.sh stop
echo "Starting docker daemon ..."
/usr/sbin/docker_daemon.sh start
echo "Deleting docker dead containers ..."
docker ps -a | grep Dead | cut -d ' ' -f 1 | xargs docker rm
echo "Starting docker container ..."
./docker-run.sh medusa
