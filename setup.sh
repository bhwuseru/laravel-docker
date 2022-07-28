#!/bin/sh

source .envrc

PROJECT_ROOT=$(pwd)
INIT_DIR_PATH="${PROJECT_ROOT}/.devcontainer/db/init"
INIT_SQLFILE_PATH="${INIT_DIR_PATH}/init.sql"
DOCKER_ENVFILE_PATH="${PROJECT_ROOT}/.devcontainer/.env"
DB_DATA_PATH="${PROJECT_ROOT}/.devcontainer/db/data"

if [ ! -d $INIT_DIR_PATH ]; then
  mkdir $INIT_DIR_PATH
fi

if [ ! -f $INIT_SQLFILE_PATH ]; then
  echo "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" > $INIT_SQLFILE_PATH
  rm -rf "$DB_DATA_PATH"
fi

# docker-composeの.envファイルが存在しない場合は作成
if [ ! -f $DOCKER_ENVFILE_PATH ]; then
  echo "PROJECT_NAME=${PROJECT_NAME}" > $DOCKER_ENVFILE_PATH
  echo "APP_NAME=${APP_NAME}" >> $DOCKER_ENVFILE_PATH
  echo "DB_DATABASE=${DB_DATABASE}" >> $DOCKER_ENVFILE_PATH
  echo "DB_PASSWORD=${DB_PASSWORD}" >> $DOCKER_ENVFILE_PATH
  echo "DB_USER=${DB_USER}" >> $DOCKER_ENVFILE_PATH
fi
