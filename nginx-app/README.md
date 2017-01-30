nginx-app
====

コンテナが切り替わってることを確認するためのappサンプルです。

これを実行する前にregistryの準備が必要です。

## 実行方法

`sh` ディレクトリの `build.sh` に下記の内容が含まれています。

## docker hostの用意

```
$ docker-machine create -d virtualbox \
    --engine-insecure-registry $(docker-machine ip container-registry):5000 \
    --engine-opt bip=172.100.42.1/16 \
    build-app
$ docker-machine env build-app
$ eval $(docker-machine env build-app)
```

## Build

```
$ docker build -t $(docker-machine ip container-registry):5000/nginx-app:latest .
```

## Push

```
$ docker push $(docker-machine ip container-registry):5000/nginx-app:latest
```
