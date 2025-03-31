#!/bin/sh
DOCKER_IMAGE=${1:-registry.gitlab.com/raspi-alpine/builder/master:latest}


docker run \
  --rm \
  -it \
  -e "DEFAULT_TIMEZONE=Europe/Zurich" \
  -e "DEFAULT_KERNEL_MODULES=*" \
  -e "ARCH=aarch64" \
  -e "ALPINE_BRANCH=v3.20" \
  -e "DEFAULT_HOSTNAME=photobooth" \
  -e "SIZE_ROOT_FS=4G" \
  -e "SIZE_ROOT_PART=4G" \
  -v "$PWD":/input \
  -v "$PWD":/output \
  "$DOCKER_IMAGE"
