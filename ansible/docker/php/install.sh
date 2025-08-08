#!/bin/sh

LARAVEL_DIR="/var/www/html/${PROJECT_NAME}"

# Laravel メジャーバージョン抽出
LARAVEL_MAJOR_VERSION=$(echo "$LARAVEL_VERSION" | cut -d'.' -f1)

# Laravel Installer がなければインストール
if ! command -v laravel >/dev/null 2>&1; then
  echo "Laravel Installer をインストール中..."
  composer global require laravel/installer
  export PATH="$HOME/.composer/vendor/bin:$HOME/.config/composer/vendor/bin:$PATH"
fi

# Laravel プロジェクトを初回作成
if [ ! -d "$LARAVEL_DIR" ]; then
  if [ "$LARAVEL_MAJOR_VERSION" -ge 12 ]; then
    echo "Laravel $LARAVEL_VERSION (React Starter) を構築中..."
    ~/.config/composer/vendor/bin/laravel new --git "${PROJECT_NAME}"
  else
    echo "Laravel $LARAVEL_VERSION を composer 経由で作成中..."
    composer create-project laravel/laravel="$LARAVEL_VERSION" "${PROJECT_NAME}" --prefer-dist
  fi
fi
