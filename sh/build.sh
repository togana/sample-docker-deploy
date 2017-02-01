#!/bin/sh
set -eu

tag=${1:-"latest"}

cd ./nginx-app
docker-machine env build
eval $(docker-machine env build)

docker build -t $(docker-machine ip container-registry):5000/nginx-app:${tag} .
docker push $(docker-machine ip container-registry):5000/nginx-app:${tag}
