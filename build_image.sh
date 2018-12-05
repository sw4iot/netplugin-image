#!/bin/bash

set -euo pipefail

REPOSITORY="contivbase"
NETPLUGIN_BINARIES="netplugin netmaster netctl contivk8s"
NETPLUGIN_CONTAINER_TAG=test
IMAGE=$REPOSITORY:${NETPLUGIN_CONTAINER_TAG}

function get_image_id() {
	docker inspect --format '{{.ID}}' $IMAGE || :
}

rm -rf scripts/bin
mkdir scripts/bin

# it's expected that makefile targets compile-with-docker and
# binaries-from-container have already been run
tar c -C bin $NETPLUGIN_BINARIES | tar x -C scripts/bin

old_image=$(get_image_id)

cd scripts/

docker build -t $IMAGE -t $REPOSITORY:latest .

new_image=$(get_image_id)

if [ "$old_image" != "" ] && [ "$old_image" != "$new_image" ]; then
    echo Removing old image $old_image
	docker rmi -f $old_image >/dev/null 2>&1 || true
fi
