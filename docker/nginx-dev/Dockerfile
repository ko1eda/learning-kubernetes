FROM nginx:1.14.1-alpine

LABEL author="Christopher Koleda" version="1.0.0"

ADD ./docker/nginx/nginx.conf /etc/nginx/
ADD ./docker/nginx/laravel.conf /etc/nginx/sites-enabled/default

# append the root www-data to root group to deal with windows volume permission issues
RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash \
    && adduser -D -H -u 1001 -g 1001 -s /bin/bash www-data

# add usermod
# RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
# RUN apk --no-cache add shadow && usermod -g root www-data

ARG PHP_UPSTREAM_CONTAINER=127.0.0.1
ARG PHP_UPSTREAM_PORT=9000

# Set upstream conf and remove the default conf
RUN echo "upstream php-upstream { server ${PHP_UPSTREAM_CONTAINER}:${PHP_UPSTREAM_PORT}; }" > /etc/nginx/conf.d/upstream.conf \
    && rm /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html 

EXPOSE 80 443

CMD nginx