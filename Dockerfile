
# ==============================================================================
#  node and build stage
FROM node:20.3-alpine3.17 as build
 
WORKDIR /

#region - install brotli
ENV BROTLI_VERSION 1.0.9

RUN apk add --no-cache --virtual .build-deps \
        bash \
        cmake \
        curl \
        gcc \
        make \
        musl-dev \
    && mkdir -p /usr/src \
    && curl -LSs https://github.com/google/brotli/archive/v$BROTLI_VERSION.tar.gz | tar xzf - -C /usr/src \
    && cd /usr/src/brotli-$BROTLI_VERSION \
    && ./configure-cmake --disable-debug && make -j$(getconf _NPROCESSORS_ONLN)

RUN cp /usr/src/brotli-$BROTLI_VERSION/brotli /usr/local/bin/brotli
#endregion - install brotli

USER node
ARG HOST_UI_PATH=${HOST_UI_PATH} 

WORKDIR /app

COPY --chown=node:node  $HOST_UI_PATH/ .
COPY --chown=node:node $HOST_UI_PATH/package.json ./
COPY --chown=node:node $HOST_UI_PATH/package-lock.json ./
RUN npm config set registry https://registry.npmjs.org/
RUN npm ci

#
RUN npm run build.client
RUN npm run build.server

COPY --chown=node:node ./docker/build/entrypoint.sh /usr/local/bin/entrypoint.sh
#
RUN chmod +x /usr/local/bin/entrypoint.sh
#ENTRYPOINT ["/bin/sh" , "/usr/local/bin/entrypoint.sh" ]
RUN /usr/local/bin/entrypoint.sh

# ==============================================================================
#  node
FROM node:20.3-alpine3.17 as node
USER node
ARG HOST_UI_PATH=${HOST_UI_PATH} 
ARG NODE_PORT=${NODE_PORT} 
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/server ./server
COPY --from=build /app/node_modules ./node_modules
#COPY $HOST_UI_PATH/frontend/package.server.json ./package.json 
COPY $HOST_UI_PATH/.env* ./
COPY $HOST_UI_PATH/package*.json ./


COPY --chown=node:node  ./docker/node/entrypoint.sh /usr/local/bin/entrypoint.sh
 
RUN chmod +x /usr/local/bin/entrypoint.sh
 
#use /bin/sh as alpine version has no /bin/bash installed
ENTRYPOINT ["/bin/sh" , "/usr/local/bin/entrypoint.sh" ]

EXPOSE $NODE_PORT


# ==============================================================================
FROM php:7.4.13-fpm as php


ARG HOST_USER
ARG HOST_UID 
ARG HOST_GID 
ARG HOST_API_PATH=${HOST_API_PATH} 

ENV PHP_OPCACHE_ENABLE=1
ENV PHP_OPCACHE_ENABLE_CLI=0
#checks if any scripts changed by enabling validate_timestamps 
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=1 
ENV PHP_OPCACHE_REVALIDATE_FREQ=1



RUN apt-get update -y
# libjpeg-dev
RUN apt-get install -y --no-install-recommends unzip zip libpq-dev openssl libcurl4-openssl-dev libwebp-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libpng-dev libxpm-dev libonig-dev  libxml2-dev pkg-config libssl-dev libzip-dev zip unzip



RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini   
COPY ./docker/php/local.ini /usr/local/etc/php/conf.d/local.ini
COPY ./docker/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf 
COPY ./docker/php/opcache.ini /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini


# to set the location of the PHP configuration file that PECL should use
#RUN pecl config-set php_ini /etc/php.ini 
RUN pecl install mongodb
RUN docker-php-ext-enable mongodb

# install redis
RUN pecl install -o -f redis \
    && rm -rf /tmp/pear
RUN docker-php-ext-enable redis


RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-configure opcache
RUN docker-php-ext-configure zip
RUN docker-php-ext-install -j "$(nproc)" pdo pdo_mysql mbstring bcmath curl opcache exif pcntl gd zip 

#Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
 
# Create system user to run Composer and Artisan Commands
#RUN useradd -G www-data,root -u $HOST_UID -d /home/$HOST_USER $HOST_USER

RUN addgroup --gid $HOST_GID $HOST_USER && adduser --uid $HOST_UID --gid $HOST_GID --home /home/matchinguser --gecos "" --disabled-password $HOST_USER

RUN usermod -aG www-data,root $HOST_USER

RUN mkdir -p /home/$HOST_USER/.composer && \
    chown -R $HOST_USER:$HOST_USER /home/$HOST_USER

WORKDIR /var/www


COPY --chown=$HOST_USER:$HOST_USER $HOST_API_PATH/ .


# copy to /usr/local/bin
COPY --chown=$HOST_USER:$HOST_USER ./docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
 


#install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN chmod -R 755 /var/www/storage
RUN chmod -R 755 /var/www/bootstrap
RUN chmod +x /usr/local/bin/entrypoint.sh
USER $HOST_USER
EXPOSE 9000
ENTRYPOINT ["/bin/bash" , "/usr/local/bin/entrypoint.sh" ]


 
# ==============================================================================
#  nginx
# FROM nginx:1.24.0-alpine as nginx

FROM tsl05164/nginx-http3:latest as nginx 

RUN chown -R nginx:nginx /etc/nginx
RUN chown -R nginx:nginx /var/log/nginx
COPY --chown=nginx:nginx ./docker/nginx/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh 

USER nginx
RUN mkdir -p /etc/nginx/tmp
RUN mkdir -p /etc/nginx/local/proxies/common
RUN mkdir -p /etc/nginx/local/conf.d
RUN mkdir -p /etc/nginx/agents_conf 
 
COPY --from=build /app/dist /var/www/html
 

ENTRYPOINT ["/bin/sh" , "/usr/local/bin/entrypoint.sh"] 