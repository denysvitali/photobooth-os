#!/bin/sh
DOCKER_IMAGE=${1:-registry.gitlab.com/raspi-alpine/builder/master:latest}


docker run \
  --rm \
  --env-file .env \
  -v "$PWD":/input \
  -v "$PWD/output":/output \
  "$DOCKER_IMAGE"
