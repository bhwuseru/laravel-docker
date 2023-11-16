#!/bin/sh

#### Docker Composeの設定ファイルと環境変数を初期化するスクリプト ####

# .envrcファイルが存在しない場合は新規作成
if [ ! -f .envrc ]; then
  cat .envrc.example > .envrc
  printf  "Created a new .env file for Docker Compose. \n Please fill in the settings in the .env file."
  return;
fi

# docker-compose.ymlの.envファイルを生成するための環境変数を読み込む
source .envrc

# 初期状態の場合はこのディレクトリ名がパスデフォルトパス
DEFAUL_NAME_DIR_PATH="${PROJECT_ROOT}/.devcontainer"

# 初期状態のディレクトリパスの場合はプロジェクトディレクトリパスに変更する
if [ -d "$DEFAUL_NAME_DIR_PATH" ]; then
	mv "$DEFAUL_NAME_DIR_PATH" "${PROJECT_NAME_DIR_PATH}"
fi

DB_INIT_DIR_PATH="${PROJECT_NAME_DIR_PATH}/db/init" 
# db/initディレクトリが存在する場合は削除
if [  -d "$DB_INIT_DIR_PATH" ]; then
  rm -rf "$DB_INIT_DIR_PATH"
fi

# db/initディレクトリ作成
mkdir "$DB_INIT_DIR_PATH"

DOCKER_ENVFILE_PATH="${PROJECT_NAME_DIR_PATH}/.env"
# docker-composeの.envファイルが存在しない場合は作成
if [ ! -f "$DOCKER_ENVFILE_PATH" ]; then
  echo "PROJECT_NAME=${PROJECT_NAME}" > "$DOCKER_ENVFILE_PATH"
fi

# docker-composeの.envファイルを生成
{
  echo "VOLUME_PATH=${VOLUME_PATH}"
  echo "NODEJS_VERSION=${NODEJS_VERSION}"
  echo "LARAVEL_VERSION=${LARAVEL_VERSION}"
  echo "APP_NAME=${APP_NAME}"
  echo "DB_DATABASE=${DB_DATABASE}"
  echo "DB_USER=${DB_USER}"
  echo "USER=${USER}"
  echo "DB_PASSWORD=${DB_PASSWORD}"
  echo "PROXY_PUBLIC_PORT=${PROXY_PUBLIC_PORT}"
  echo "PROXY_SSH_PORT=${PROXY_SSH_PORT}"
  echo "VITE_PORT=${VITE_PORT}"
  echo "REACT_PORT=${REACT_PORT}"
  echo "PHP_SERVE_PORT=${PHP_SERVE_PORT}"
  echo "PHP_MYADMIN_PUBLIC_PORT=${PHP_MYADMIN_PUBLIC_PORT}"
  echo "NODE_PORT=${NODE_PORT}"
  echo "MEMORY_LIMIT=${MEMORY_LIMIT}"
  echo "UPLOAD_LIMIT=${UPLOAD_LIMIT}"
}  >> "$DOCKER_ENVFILE_PATH"

# 初回に作成するSQLファイルを格納するディレクトリが存在しない場合
if [ ! -d "$DB_INIT_DIR_PATH" ]; then
  mkdir "$DB_INIT_DIR_PATH"
fi

# 初期化時にdb/dataディレクトリは削除する
if [ -d "${PROJECT_NAME_DIR_PATH}/db/data" ]; then
  rm -rf "${PROJECT_NAME_DIR_PATH}/db/data"
fi

# SQLファイル作成
DB_INIT_SQLFILE_PATH="${DB_INIT_DIR_PATH}/init.sql"
echo "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" > "$DB_INIT_SQLFILE_PATH"

# テスト用SQLファイル作成
echo "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE}_testing CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" >> "$DB_INIT_SQLFILE_PATH"
