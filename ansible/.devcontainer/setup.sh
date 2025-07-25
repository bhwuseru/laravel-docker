#!/bin/bash
# 初回devcontainer.json用のセットアップスクリプト
set -e

LARAVEL_DIR="/var/www/html/${PROJECT_NAME}"

if [ -d "$LARAVEL_DIR" ]; then
  cd "$LARAVEL_DIR"
  composer install
  npm install
else
  echo "Laravel project not found at $LARAVEL_DIR, skipping setup."
fi