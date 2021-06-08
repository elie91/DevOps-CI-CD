FROM php:7.4-fpm
WORKDIR /usr/share/nginx/html
RUN apt-get update && apt-get install -y libicu-dev gnupg2 wget apt-utils
RUN apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql
RUN apt-get clean
RUN pecl install apcu
RUN docker-php-ext-enable apcu
RUN docker-php-ext-install intl opcache
RUN apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-install zip
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN apt-get install -y git
ADD php.ini /usr/local/etc/php/conf.d/php.ini
COPY composer.json .
RUN composer install
COPY . .
