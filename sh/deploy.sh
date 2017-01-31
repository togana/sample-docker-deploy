#!/bin/sh
set -eu

registry=${1:-"localhost"}
tag=${2:-"latest"}

docker-machine start sample-docker-deploy
docker-machine env sample-docker-deploy
eval $(docker-machine env sample-docker-deploy)

cat << EOS > docker-compose.yml
version: '3'
services:
  web:
    image: ${registry}/nginx-app:${tag}
    ports:
      - '80:80'
    deploy:
      replicas: 2
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
EOS

docker stack deploy --compose-file docker-compose.yml sample-docker-deploy
