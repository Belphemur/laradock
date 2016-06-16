FROM  ubuntu:latest
ENV USER_ID 1000

MAINTAINER Mahmoud Zalt <mahmoud@zalt.me>

RUN DEBIAN_FRONTEND=noninteractive
RUN locale-gen en_US.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

# Install "software-properties-common" (for the "add-apt-repository")
RUN apt-get update && apt-get install -y \
    software-properties-common sudo curl

# Add the "PHP 7" ppa
RUN add-apt-repository -y \
    ppa:ondrej/php

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

# Install PHP-CLI 7, some PHP extentions and some useful Tools with APT
RUN apt-get update && apt-get install -y \
        php7.0-cli \
        php7.0-common \
        php7.0-curl \
        php7.0-json \
        php7.0-xml \
        php7.0-mbstring \
        php7.0-mcrypt \
        php7.0-mysql \
        php7.0-pgsql \
        php7.0-sqlite \
        php7.0-sqlite3 \
        php7.0-zip \
        php7.0-memcached \
        php7.0-gettext \
        sqlite3 \
        libsqlite3-dev \
        git \
        curl \
        vim \
        nano \
        nodejs \
        gettext

# Clean up, to free some space
RUN apt-get clean

# Install gulp and bower with NPM
RUN npm install -g \
    gulp \
    bower

# Add an alias for PHPUnit
RUN echo "alias phpunit='/var/www/laravel/vendor/bin/phpunit'" >> /etc/profile

#Add alias laravel
RUN echo "alias laravel='php /var/www/laravel/artisan'" >> /etc/profile

# Install Composer
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN mkdir -p /var/www/ && useradd -ms /bin/bash laravel -u $USER_ID -d /var/www/laravel

WORKDIR /var/www/laravel
