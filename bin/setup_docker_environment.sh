#!/bin/bash

# docker-compose環境のセットアップとコンテナの起動する

# .env ファイルのパスを設定
envfile_path="$(pwd)/.devcontainer/.env"

# もし .env ファイルが存在する場合は削除
if [ -f $envfile_path ]; then
    rm -f $envfile_path
fi

#  .devcontainerディレクトリ(初期状態の場合)に限り.envrcの準備処理を実行
if [ -d "$(pwd)/.devcontainer" ]; then
    # Docker Composeの環境設定を生成および実行
    . ./bin/gene_docker_compose_env.sh
fi

source .envrc && \
cd .${PROJECT_NAME} 

# dangling Dockerイメージの削除
none_images=$(docker images -f "dangling=true" -q)
if [ -n "$none_images" ]; then
    docker rmi $(docker images -f "dangling=true" -q)
fi

# Docker Composeを使用してコンテナをビルドおよび起動
docker-compose build --no-cache && \
docker-compose up -d && \

# 実行したファイルのディレクトリ位置に戻る
cd ..
