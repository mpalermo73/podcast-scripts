#!/usr/bin/env bash

for D in $(docker images | awk '/^[a-z]/ {print $1":"$2}'e) ; do docker pull $D ; done

# docker system prune -a
