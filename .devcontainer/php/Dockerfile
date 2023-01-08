FROM  php:8.2-fpm

# 引数を受け取ってコンテナ内で環境変数を定義
ARG NODEJS_VERSION
ARG LARAVEL_VERSION
ARG PROJECT_NAME
ARG PASSWORD
ARG USER
ARG PHP_DOCKER_PORT

ENV LARAVEL_VERSION=${LARAVEL_VERSION}
ENV NODEJS_VERSION=${NODEJS_VERSION}
ENV PROJECT_NAME=${PROJECT_NAME}
ENV USER=${USER}
ENV PASSWORD=${PASSWORD}
ENV PHP_DOCKER_PORT=${PHP_DOCKER_PORT}

# タイムゾーンを設定
ENV TZ=Asia/Tokyo

# ローカルからDocker環境にファイルをコピー
COPY php.ini /usr/local/etc/php/php.ini

# composerのインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# パッケージのインストール
RUN apt-get update && apt-get install -y \
    tzdata \
    zip \
    unzip \
    libonig-dev libfreetype6-dev libjpeg62-turbo-dev \
    && pecl install xdebug \
    && docker-php-ext-install pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

RUN PHP_OPENSSL=yes

# nodejs 追加
RUN curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION} | bash -
RUN apt-get install -y nodejs

# npm 経由でyarnをインストール
RUN npm install -g yarn

# 一般権限のユーザーを追加
RUN useradd -m ${USER} --uid 1000
RUN gpasswd -a ${USER} sudo
RUN echo "${USER}:${PASSWORD}" | chpasswd

# ユーザーの切替 USER ${USER}
USER ${USER}

#　作業ディレクトリに移動
WORKDIR /var/www/html