SAMPLE-DOCKER-DEPLOY
====

## 概要

docker1.12から追加された `docker swarm mode` とdocker1.13から追加された `docker stack deploy` を用いてダウンタイムのないデプロイ方法のサンプル

## 動作確認したバージョン情報

- macOS Sierra 10.12.2
- docker 1.13.0
- docker-machine 0.9.0
- docker-compose 1.10.0

## 構成

現在使用している構成は

```
local(ブラウザ) -> nginx(プロキシ) -> nginx(コンテナ) -> app(コンテナ) -> バックエンドAPI
```

上記のnginx(コンテナ)のところに[ngx_dynamic_upstream](https://github.com/cubicdaiya/ngx_dynamic_upstream)を使用してデプロイ時にapp(コンテナ)の数を倍にしてcurlを叩いてアップストリームに追加して古い方を削除するという方法を取っていました。
nginxがコンテナで実行している理由はapp(コンテナ)はportをホストに繋がず `docker network` ないのみでアクセスできるようにして複数のコンテナを実行できるようにするためでした。

今回検討している構成は

```
local(ブラウザ) -> nginx(プロキシ) -> app(コンテナ) -> バックエンドAPI
```

となる予定です。今までnginx(コンテナ)にまかせていた `docker network` のロードバランシングを `docker swarm mode` のロードバランサー(オーバーレイネットワーク)に任せることにします。
そしてデプロイ時に `docker ps -q -f name=app | xargs docker inspect --format="{{ index .Config.Labels \"com.docker.compose.container-number\" }}{{\":\"}}{{ index .ID }}{{\":\"}}{{with index .NetworkSettings.Networks \"front-tier\" }}{{ .IPAddress }}{{end}}"` のような感じの丹精込めて作られたコマンドを捨てるために `docker stack deploy` を取り入れられないかと考えました。

sampleなので実際に試す環境は下記になります。
間に挟んだりappコンテナからアクセスするだけなので今回は外しています。

```
local(ブラウザ) -> app(コンテナ)
```

## ディレクトリ構成

```
├── README.md          (このファイル)
├── nginx-app          (appのイメージ←ここは別のリポジトリを作成して管理すべきですがサンプルなのでまとめました)
├── registry           (swarmを使う場合dockrehub or registryが必須なので非公開環境を用意)
└── sh                 (実行シェル)
```

## docker-registry+swarmサーバの準備

```
$ ./sh/init.sh
```

## appのビルド

```
# args
#  - docker-registryのアクセスポイント(defalt: localhost)
#  - tag名(defalt: latest)
$ ./sh/build.sh $(docker-machine ip container-registry):5000 latest
```

## デプロイ

```
# args
#  - docker-registryのアクセスポイント(defalt: localhost)
#  - tag名(defalt: latest)
$ ./sh/deploy.sh $(docker-machine ip container-registry):5000 latest
```

## 確認

```
$ curl http://$(docker-machine ip sample-docker-deploy)
```

## 片付け

```
$ ./sh/delete.sh
```
