#!/bin/sh

# .envrcファイルが存在しない場合は新規作成
if [ ! -f .envrc ]; then
  cat .envrc.example > .envrc
fi

source .envrc

PROJECT_ROOT=$(pwd)
INIT_DIR_PATH="${PROJECT_ROOT}/.devcontainer/db/init"
INIT_SQLFILE_PATH="${INIT_DIR_PATH}/init.sql"
DOCKER_ENVFILE_PATH="${PROJECT_ROOT}/.devcontainer/.env"
DB_DATA_PATH="${PROJECT_ROOT}/.devcontainer/db/data"

# 初回に作成するsqlファイルを格納するディレクトリが存在しない場合
if [ ! -d $INIT_DIR_PATH ]; then
  mkdir $INIT_DIR_PATH
fi

# 初回に作成するsqlファイルが存在しない場合
if [ ! -f $INIT_SQLFILE_PATH ]; then
  echo "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" > $INIT_SQLFILE_PATH
  rm -rf "$DB_DATA_PATH"
fi


# docker-composeの.envファイルが存在しない場合は作成
if [ ! -f $DOCKER_ENVFILE_PATH ]; then
  echo "PROJECT_NAME=${PROJECT_NAME}" > $DOCKER_ENVFILE_PATH
  echo "APP_NAME=${APP_NAME}" >> $DOCKER_ENVFILE_PATH
  echo "DB_DATABASE=${DB_DATABASE}" >> $DOCKER_ENVFILE_PATH
  echo "DB_USER=${DB_USER}" >> $DOCKER_ENVFILE_PATH
  echo "DB_PORT=${DB_PORT}" >> $DOCKER_ENVFILE_PATH
  echo "USER=${USER}" >> $DOCKER_ENVFILE_PATH
  echo "DB_PASSWORD=${DB_PASSWORD}" >> $DOCKER_ENVFILE_PATH
  echo "PROXY_PORT=${PROXY_PORT}" >> $DOCKER_ENVFILE_PATH
  echo "BACKEND_PORT=${BACKEND_PORT}" >> $DOCKER_ENVFILE_PATH
  echo "FRONTEND_PORT=${FRONTEND_PORT}" >> $DOCKER_ENVFILE_PATH
  echo "PHP_MYADMIN_PORT=${PHP_MYADMIN_PORT}" >> $DOCKER_ENVFILE_PATH
fi
