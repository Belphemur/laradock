FROM nginx:alpine
ARG USER_ID=1000

MAINTAINER Mahmoud Zalt <mahmoud@zalt.me>

ADD nginx.conf /etc/nginx/
ADD laravel.conf /etc/nginx/sites-available/

RUN echo "upstream php-upstream { server php-fpm:9000; }" > /etc/nginx/conf.d/upstream.conf

RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u $USER_ID -D -S -G www-data www-data && exit 0 ; exit 1


RUN  apk add --no-cache openssl \
&& mkdir -p /opt/ssl \
&& cd /opt/ssl/ \
&& openssl genrsa -des3 -passout pass:x -out server.pass.key 2048 \
&& openssl rsa -passin pass:x -in server.pass.key -out server.key \
&& rm server.pass.key \
&& openssl req -new -key server.key -out server.csr -subj "/C=DE/ST=Nuremberg/L=Nuremberg/O=cumulus.local/OU=cumulus.local/CN=cumulus.local" \
&& openssl x509 -req -sha256 -days 365000 -in server.csr -signkey server.key -out server.crt \
&& apk del openssl 

CMD ["nginx"]

EXPOSE 80 443
