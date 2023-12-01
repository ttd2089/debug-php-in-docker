FROM php:8.2.13-fpm AS base

WORKDIR /var/www/html

FROM base AS dev

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

FROM base AS prod

COPY ./src /var/www/html
