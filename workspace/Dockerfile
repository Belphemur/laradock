FROM  ubuntu:latest

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
RUN apt-get update && apt-get install -y --force-yes \
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
        php7.0-gd \
        php7.0-xdebug \
        php7.0-intl \
        php-dev \
        libcurl4-openssl-dev \
        libedit-dev \
        libssl-dev \
        libxml2-dev \
        xz-utils \
        php7.0-gettext \
        sqlite3 \
        libsqlite3-dev \
        git \
        curl \
        vim \
        nodejs \
        zsh \
	dnsutils

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

# Install optional software
ARG INSTALL_PRESTISSIMO=false
RUN if [ "$INSTALL_PRESTISSIMO" = true ] ; then \
        composer global require "hirak/prestissimo:^0.3"; \
fi

# To debug memecached
RUN apt-get install telnet

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG USER_NAME=laravel
ARG USER_ID=1000

RUN mkdir -p /var/www/$USER_NAME && useradd -ms /bin/zsh $USER_NAME -u $USER_ID && \
	git clone git://github.com/robbyrussell/oh-my-zsh.git /home/$USER_NAME/.oh-my-zsh && \
	chown -R $USER_NAME: -R /home/$USER_NAME && \
        chown -R $USER_NAME: -R /var/www/$USER_NAME
	

ADD zshrc /home/laravel/.zshrc

ADD xdebug.ini /etc/php/7.0/mods-available/xdebug.ini

ENV _PHP_IDE_CONFIG="serverName=commandline"
ENV _XDEBUG_CONFIG="idekey=PHPSTORM remote_host=172.17.0.1"

RUN mkdir -p /var/run/laravel && chown -R $USER_NAME: -R /var/run/laravel

WORKDIR /var/www/laravel


