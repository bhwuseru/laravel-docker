#!/bin/sh

source .envrc

PROJECT_NAME=$(pwd)
INIT_DIR_PATH="${PROJECT_ROOT}/.devcontainer/db/init"
INIT_SQLFILE_PATH="${INIT_DIR_PATH}/init.sql"

if [ ! -d $INIT_DIR_PATH ]; then
  mkdir $INIT_DIR_PATH
fi

if [ ! -f $INIT_SQLFILE_PATH ]; then
  echo "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" > $INIT_SQLFILE_PATH
fi