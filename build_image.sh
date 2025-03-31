#!/bin/sh
DOCKER_IMAGE=${1:-registry.gitlab.com/raspi-alpine/builder/master:latest}


docker run \
  --rm \
  -it \
  --env-file .env \
  -v "$PWD":/input \
  -v "$PWD":/output \
  "$DOCKER_IMAGE"
