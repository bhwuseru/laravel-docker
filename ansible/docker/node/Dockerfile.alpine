# FROM node:20.17.0-alpine3.20
FROM node:23.8.0-alpine3.21

# コンテナ内の環境変数を定義するための引数
ARG PROJECT_NAME
ARG PASSWORD
ARG USER

# 環境変数を設定する
ENV PROJECT_NAME=${PROJECT_NAME}
ENV USER=${USER}
ENV PASSWORD=${PASSWORD}
ENV TZ=Asia/Tokyo
ENV PATH="/opt/venv/bin:$PATH"

# ユーザーをルートに切り替える
USER root

# 必要なパッケージをインストール
RUN apk add --no-cache \
  bash \
  git \
  sudo \
  python3 \
  py3-pip \
  curl \
  icu-libs  # glibc の代わりに icu-libs を使用

# Supervisor のインストール (仮想環境を使用)
RUN python3 -m venv /opt/venv && \
  . /opt/venv/bin/activate && \
  pip install --upgrade pip && \
  pip install supervisor

# Supervisor の設定
RUN mkdir -p /etc/supervisor \
  && echo_supervisord_conf > /etc/supervisor/supervisord.conf

# sudo実行時のパスワード入力を省略
RUN echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node

# Node.jsをインストールし、npmをアップグレード
RUN apk add --no-cache nodejs npm \
  && npm install -g npm@latest \
  && npm install -g pm2

# npm のキャッシュディレクトリの権限を修正 (EACCES対策)
RUN mkdir -p /home/node/.npm && chown -R node:node /home/node/.npm

# .bashrcをコピー
COPY .bashrc /home/node/.bashrc

# `/var/www/html` の作成とパーミッション設定
RUN mkdir -p /var/www/html && chown -R node:node /var/www/html

# ディレクトリを変更してからユーザーを切り替える
WORKDIR /var/www/html

# nodeユーザーに切り替える
USER node

# CMD ["/usr/local/bin/start_supervisor.sh"]