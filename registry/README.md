registry
====

dockerhubを使うことができないときを想定してdocker-registryを自前で立てれるようにしています。
`sh` ディレクトリのinit.shに下記の内容が含まれています。

## docker hostの用意

```
# bipを設定しているのは自動で172.17.0.0/16がサブネットとして設定されてしまい他のネットワークと接続できなくなる可能性があるためです
$ docker-machine create -d virtualbox \
    --engine-opt bip=172.100.42.1/16 \
    container-registry
$ docker-machine env container-registry
$ eval $(docker-machine env container-registry)
```

## 実行

```
$ docker-compose up -d
```
