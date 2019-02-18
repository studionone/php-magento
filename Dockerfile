FROM php:7.1-apache

ENV TERM "xterm-256color"
ENV COLUMNS 200
ENV DEBIAN_FRONTEND "noninteractive"
ENV COMPOSER_HOME "/root/composer"
ENV LANG "C.UTF-8"
ENV LANGUAGE "C.UTF-8"
ENV LC_ALL "C.UTF-8"

# Install base packages
RUN apt-get update -qq && apt-get install -y \
       gnupg \
       libssl-dev \
    && apt-get install -y locales -qq \
    && locale-gen en_AU \
    && locale-gen en_AU.UTF-8 \
    && dpkg-reconfigure locales \
    && locale-gen C.UTF-8 \
    && dpkg-reconfigure locales \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update && apt-get upgrade -y && apt-get install -y \
       apt-transport-https \
       build-essential \
       ca-certificates \
       cron \
       curl \
       git \
       libbz2-dev \
       libfreetype6-dev \
       libicu-dev \
       libjpeg-dev \
       libmcrypt-dev \
       libmemcached-dev \
       libmemcachedutil2 \
       libpng-dev \
       libpq-dev \
       libsasl2-dev \
       libxslt-dev \
       nano \
       software-properties-common \
       sudo \
       unzip \
       wget \
       xz-utils \
       zip

# Install Project dependencies (PHP/Composer/Node/Grunt), then clean temporary files
RUN docker-php-ext-install bz2 soap calendar iconv intl xsl mbstring mcrypt mysqli opcache pdo_mysql pdo_pgsql pgsql zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd bcmath \
    && pecl install memcached redis \
    && docker-php-ext-enable memcached.so redis.so \
    && a2enmod rewrite \
    && echo "memory_limit=2G" > /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "max_execution_time=18000" > /usr/local/etc/php/conf.d/max-execution-time.ini \
    && echo "max_input_time=6000" > /usr/local/etc/php/conf.d/max-input-time.ini \
    && echo "max_input_vars=5000" > /usr/local/etc/php/conf.d/max-input-vars.ini \
    && echo "post_max_size=256M" > /usr/local/etc/php/conf.d/post-max-size.ini \
    && echo "upload_max_filesize=256M" > /usr/local/etc/php/conf.d/upload-max-filesize.ini \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && export PATH=$COMPOSER_HOME/vendor/bin:$PATH \
    && composer self-update && composer global require hirak/prestissimo \
    && cd /tmp \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get update && apt-get install -y nodejs \
    && npm install -g grunt-cli \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
