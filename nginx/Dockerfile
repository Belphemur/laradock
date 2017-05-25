FROM nginx:alpine
ARG USER_ID=1000

MAINTAINER Mahmoud Zalt <mahmoud@zalt.me>

ADD nginx.conf /etc/nginx/
ADD laravel.conf /etc/nginx/sites-available/

RUN echo "upstream php-upstream { server php-fpm:9000; }" > /etc/nginx/conf.d/upstream.conf

RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u $USER_ID -D -S -G www-data www-data && exit 0 ; exit 1

CMD ["nginx"]

EXPOSE 80 443
