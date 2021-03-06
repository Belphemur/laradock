FROM php:7.2-fpm-alpine3.7
ARG USER_ID=1000
ARG LOCALE_VERSION=2.28-r0

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Glibc and Locales
RUN apk --no-cache add ca-certificates wget libgcc && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${LOCALE_VERSION}/glibc-${LOCALE_VERSION}.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${LOCALE_VERSION}/glibc-dev-${LOCALE_VERSION}.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${LOCALE_VERSION}/glibc-bin-${LOCALE_VERSION}.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${LOCALE_VERSION}/glibc-i18n-${LOCALE_VERSION}.apk && \
    apk add glibc-bin-${LOCALE_VERSION}.apk glibc-${LOCALE_VERSION}.apk glibc-i18n-${LOCALE_VERSION}.apk glibc-dev-${LOCALE_VERSION}.apk && \
    rm glibc*.apk

COPY ./locales/locales.txt /tmp/locales.txt
RUN cat /tmp/locales.txt | xargs -i /usr/glibc-compat/bin/localedef -i {} -f UTF-8 {}.UTF-8 \
    && rm /tmp/locales.txt

# intl, zip, soap, ldap
RUN apk add --update --no-cache libintl icu icu-dev libxml2-dev openldap-dev libldap \
    && docker-php-ext-install intl zip soap ldap \
    && apk del icu-dev libxml2-dev openldap-dev

# mysqli, pdo, pdo_mysql, pdo_pgsql
RUN apk add --update --no-cache postgresql-dev postgresql \
    && docker-php-ext-install mysqli pdo pdo_mysql pdo_pgsql \
    && apk del postgresql-dev

# gd, iconv
RUN apk add --update --no-cache \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        freetype \
        libjpeg-turbo \
        libpng \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" gd \
    && apk del libpng-dev freetype-dev  libjpeg-turbo-dev

# gmp
RUN apk add --update --no-cache gmp gmp-dev \
    && docker-php-ext-install gmp \
    && apk del gmp-dev


# php-redis
ENV PHPREDIS_VERSION="3.1.6"

RUN docker-php-source extract \
    && curl -L -o /tmp/redis.tar.gz "https://github.com/phpredis/phpredis/archive/${PHPREDIS_VERSION}.tar.gz" \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install redis \
    && docker-php-source delete

# Memcached
RUN apk add --no-cache libmemcached-dev zlib-dev cyrus-sasl-dev git \
    && docker-php-source extract \
    && git clone --branch php7 https://github.com/php-memcached-dev/php-memcached.git /usr/src/php/ext/memcached/ \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && docker-php-source delete \
    && apk del --no-cache zlib-dev cyrus-sasl-dev git


# apcu
RUN docker-php-source extract \
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apk del .phpize-deps-configure \
    && docker-php-source delete

# imagick
RUN apk add --update --no-cache autoconf g++ imagemagick-dev pcre-dev libtool make \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apk del autoconf g++ libtool make pcre-dev

# ssh2
RUN apk add --update --no-cache autoconf g++ libtool make pcre-dev libssh2 libssh2-dev \
    && pecl install ssh2-1 \
    && docker-php-ext-enable ssh2 \
    && apk del autoconf g++ libtool make pcre-dev


# xdebug && igbinary
RUN docker-php-source extract \
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    &&  pecl install igbinary \
    && docker-php-ext-enable igbinary \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del .phpize-deps-configure \
    && docker-php-source delete

# set recommended opcache PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# set recommended apcu PHP.ini settings
# see https://secure.php.net/manual/en/apcu.configuration.php
RUN { \
        echo 'apc.shm_segments=1'; \
        echo 'apc.shm_size=256M'; \
        echo 'apc.num_files_hint=7000'; \
        echo 'apc.user_entries_hint=4096'; \
        echo 'apc.max_file_size=1M'; \
        echo 'apc.serializer=igbinary'; \
        echo 'apc.stat=1'; \
} > /usr/local/etc/php/conf.d/apcu-recommended.ini

ADD ./laravel.pool.conf /usr/local/etc/php-fpm.d/
ADD ./php.d/laravel.ini /usr/local/etc/php/conf.d
ADD ./php.d/xdebug.ini /usr/local/etc/php/conf.d

RUN apk --no-cache add shadow \
    && usermod -u $USER_ID www-data \
    && apk del shadow

WORKDIR /var/www/laravel

EXPOSE 9000
CMD ["php-fpm"]
