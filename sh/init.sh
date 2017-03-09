#!/bin/sh
set -eu

# init_docker_registry
cd $(cd $(dirname $0);pwd)/../registry
docker-machine create -d virtualbox \
  --engine-opt bip=172.18.42.1/24 \
  container-registry
docker-machine env container-registry
eval $(docker-machine env container-registry)

# create registry
docker-compose up -d

# init_build_server
docker-machine create -d virtualbox \
  --engine-insecure-registry $(docker-machine ip container-registry):5000 \
  --engine-opt bip=172.18.42.1/24 \
  build

# init_deploy_server
docker-machine create -d virtualbox \
  --engine-insecure-registry $(docker-machine ip container-registry):5000 \
  --engine-opt bip=172.18.42.1/24 \
  sample-docker-deploy
docker-machine env sample-docker-deploy
eval $(docker-machine env sample-docker-deploy)

# create docker_gwbridge
docker network create \
  --opt com.docker.network.bridge.enable_icc=false \
  --subnet=172.18.43.1/24 \
  docker_gwbridge

# init swarm
docker swarm init --advertise-addr $(docker-machine ip sample-docker-deploy)
