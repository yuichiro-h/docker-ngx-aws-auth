FROM alpine

ENV NGINX_VERSION 1.12.2
ENV NGINX_AWS_AUTH_VERSION 1.1.1

RUN apk --update add curl build-base openssl-dev zlib-dev pcre-dev \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && mkdir -p /src \
    && curl -SL https://github.com/anomalizer/ngx_aws_auth/archive/${NGINX_AWS_AUTH_VERSION}.tar.gz | tar zx -C /src \
    && curl -SL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -zx -C /src \
    && cd /src/nginx-${NGINX_VERSION} \
    && ./configure \
 		--prefix=/etc/nginx \
 		--sbin-path=/usr/sbin/nginx \
 		--conf-path=/etc/nginx/nginx.conf \
 		--user=nginx \
 		--group=nginx \
 		--with-http_ssl_module \
        --with-http_auth_request_module \
 		--with-http_gzip_static_module \
        --add-module=/src/ngx_aws_auth-${NGINX_AWS_AUTH_VERSION} \
    && make \
    && make install \
    && apk del curl build-base \
    && rm -rf /src \
    && rm -rf /var/cache/apk/*

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]