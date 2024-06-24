image := 'un1def/emilua'
version := '0.8.3'

_list:
  @just --list

build:
  #!/bin/sh
  if docker image inspect '{{image}}:{{version}}' > /dev/null 2>&1; then
    echo '{{image}}:{{version}} already exists'
    exit 1
  fi
  build_date=$(TZ=UTC date --iso-8601=seconds)
  docker build . \
    --pull --no-cache --force-rm \
    --build-arg='IMAGE_NAME={{image}}' \
    --build-arg='VERSION={{version}}' \
    --build-arg="BUILD_DATE=${build_date}" \
    --tag '{{image}}:{{version}}' --tag '{{image}}:latest'
