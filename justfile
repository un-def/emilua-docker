image := 'un1def/emilua'
version := '0.10.1'

_list:
  @just --list --unsorted

build:
  #!/bin/sh
  if docker image inspect '{{image}}:{{version}}' > /dev/null 2>&1; then
    echo '{{image}}:{{version}} already exists'
    exit 1
  fi
  build_date=$(date --utc --iso-8601=seconds)
  docker build . \
    --pull --no-cache \
    --build-arg='VERSION={{version}}' \
    --build-arg="BUILD_DATE=${build_date}" \
    --tag '{{image}}:{{version}}' --tag '{{image}}:latest'

push:
  docker push '{{image}}:{{version}}'
  docker push '{{image}}:latest'
