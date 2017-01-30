#!/bin/sh

registry=${1:-"localhost"}
tag=${2:-"latest"}

cd ./nginx-app
docker-machine create -d virtualbox \
    --engine-insecure-registry ${registry} \
    --engine-opt bip=172.100.42.1/16 \
    build-app
docker-machine start build-app
docker-machine env build-app
eval $(docker-machine env build-app)

docker build -t ${registry}/nginx-app:${tag} .
docker push ${registry}/nginx-app:${tag}
