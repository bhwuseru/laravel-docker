# FROM php:8.2-rc-fpm-buster
# FROM php:8.0.22RC1-fpm-buster
FROM php:7.4.30-fpm-buster

# 引数を受け取ってコンテナ内で環境変数を定義
ARG PROJECT_NAME
ENV PROJECT_NAME=${PROJECT_NAME}
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

RUN rm -r /var/lib/apt/lists/*
RUN PHP_OPENSSL=yes
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/

RUN docker-php-ext-install zip pdo_mysql mysqli mbstring gd

# composer install
COPY --from=composer /usr/bin/composer /usr/bin/composer

# xdebug install
RUN pecl install xdebug && \
docker-php-ext-enable xdebug

# npm install
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs

WORKDIR /var/www/html
