FROM php:7.4-fpm-alpine

WORKDIR /var/www/html
ADD ./config/php.conf /usr/local/etc/php-fpm.d/www.conf

RUN touch /var/log/error_log
RUN addgroup -g 1000 wp && adduser -G wp -g wp -s /bin/sh -D wp
RUN mkdir -p /var/www/html
RUN chown wp:wp /var/www/html

RUN docker-php-ext-install mysqli pdo pdo_mysql bcmath exif \
    && docker-php-ext-enable pdo_mysql bcmath exif

RUN set -ex \
    && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS imagemagick-dev libtool \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && pecl install imagick-3.4.3 \
    && docker-php-ext-enable imagick \
    && apk add --no-cache --virtual .imagick-runtime-deps imagemagick \
    && apk del .phpize-deps

RUN apk add --no-cache libpng libpng-dev && docker-php-ext-install gd && apk del libpng-dev
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
