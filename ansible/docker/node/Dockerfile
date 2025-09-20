FROM node:23-slim

# コンテナ内の環境変数を定義するための引数
ARG PROJECT_NAME
ARG PASSWORD
ARG USER

# 環境変数を設定する
ENV PROJECT_NAME=${PROJECT_NAME}
ENV USER=${USER}
ENV PASSWORD=${PASSWORD}
ENV TZ=Asia/Tokyo

# root 権限で必要なパッケージをインストール
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
  bash \
  git \
  sudo \
  curl \
  locales \
  tzdata \
  && rm -rf /var/lib/apt/lists/*

# sudo実行時のパスワード入力を省略
RUN echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node

# npm をアップデートし、pm2 / typescript / ts-node をグローバルインストール
RUN npm install -g npm@latest \
    pm2 \
    typescript \
    ts-node

# npm のキャッシュディレクトリの権限を修正 (EACCES対策)
RUN mkdir -p /home/node/.npm && chown -R node:node /home/node/.npm

# .bashrcをコピー
COPY .bashrc /home/node/.bashrc

# `/var/www/html` の作成とパーミッション設定
RUN mkdir -p /var/www/html && chown -R node:node /var/www/html

# 作業ディレクトリ
WORKDIR /var/www/html

# node ユーザーに切り替え
USER node

# デフォルトの起動コマンド (例: pm2-runtime)
# CMD ["pm2-runtime", "start", "ecosystem.config.js"]