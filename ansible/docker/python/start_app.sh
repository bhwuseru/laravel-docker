#/bin/sh

# venvを有効化
. ./venv/bin/activate
# 開発サーバー立ち上げ
uvicorn main:app --host 0.0.0.0 --reload