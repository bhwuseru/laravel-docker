# FROM php:8.2-rc-fpm-buster
FROM php:8.0.22RC1-fpm-buster
# FROM php:7.4.30-fpm-buster

# 引数を受け取ってコンテナ内で環境変数を定義
ARG LARAVEL_VERSION
ARG PROJECT_NAME
ARG PASSWORD
ARG USER
ENV LARAVEL_VERSION=${LARAVEL_VERSION}
ENV PROJECT_NAME=${PROJECT_NAME}
ENV PASSWORD=${PASSWORD}
ENV USER=${USER}

# ローカルからDocker環境にファイルをコピー
COPY php.ini /usr/local/etc/php/php.ini

# php module
RUN apt-get update && apt-get install -y \
    vim \
    zlib1g-dev \
    git \
    libzip* \
    libonig-dev \
    libc-client-dev \
    libkrb5-dev \
    libzip-dev \
    libjpeg-dev \
    libpng-dev \
    libzip-dev \
    libpq-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev

# nodejs 追加
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs

RUN rm -r /var/lib/apt/lists/*

# docker php設定
RUN PHP_OPENSSL=yes
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
RUN docker-php-ext-install zip pdo_mysql mysqli mbstring gd

# composer追加
COPY --from=composer /usr/bin/composer /usr/bin/composer

# xdebug インストール
RUN pecl install xdebug && \
docker-php-ext-enable xdebug

# 一般権限のユーザーを追加
RUN useradd -m ${USER} --uid 1000
RUN gpasswd -a ${USER} sudo
RUN echo "${USER}:${PASSWORD}" | chpasswd

# ユーザーの切替 USER ${USER}
USER ${USER}

#　作業ディレクトリに移動
WORKDIR /var/www/html
