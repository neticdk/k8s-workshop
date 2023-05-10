#!/usr/bin/env bash

path=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)
docker run --name=gogs -d -p 10022:22 -p 10880:3000 -v $path/data:/data gogs/gogs
