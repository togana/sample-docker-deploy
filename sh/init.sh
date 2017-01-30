#!/bin/sh

# init_docker_registry
cd ./registry
docker-machine create -d virtualbox \
    --engine-opt bip=172.100.42.1/16 \
    container-registry
docker-machine start container-registry
docker-machine env container-registry
eval $(docker-machine env container-registry)

# create registry
docker-compose up -d

# init_deploy_server
docker-machine create -d virtualbox \
  --engine-insecure-registry $(docker-machine ip container-registry):5000 \
  --engine-opt bip=172.100.42.1/16 \
  sample-docker-deploy
docker-machine env sample-docker-deploy
eval $(docker-machine env sample-docker-deploy)

# create docker_gwbridge
docker network create \
  --opt com.docker.network.bridge.enable_icc=false \
  --subnet=172.100.43.1/16 \
  docker_gwbridge

# init swarm
docker swarm init --advertise-addr $(docker-machine ip sample-docker-deploy)
