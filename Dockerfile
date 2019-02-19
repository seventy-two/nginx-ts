FROM alpine:3.8 as build-nginx

ENV PATH $PATH:/usr/local/nginx/sbin

ENV NGINX_VERSION 1.14.2
ENV NGINX_TS_VERSION 0.1.1

RUN mkdir /src /config /logs /data

# Build dependencies.
RUN apk add --update \
  build-base \
  ca-certificates \
  curl \
  gcc \
  libc-dev \
  libgcc \
  linux-headers \
  make \
  musl-dev \
  openssl \
  openssl-dev \
  pcre \
  pcre-dev \
  pkgconf \
  pkgconfig \
  zlib-dev \
  lame \
  libogg \
  libass \
  libvpx \
  libvorbis \
  libwebp \
  libtheora \
  opus \
  rtmpdump \
  x264-dev \
  x265-dev 


# get nginx source
WORKDIR /src
RUN set -x && \
  wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
  rm nginx-${NGINX_VERSION}.tar.gz && \

# get nginx-ts module
  wget https://github.com/arut/nginx-ts-module/archive/v${NGINX_TS_VERSION}.tar.gz && \
  tar zxf v${NGINX_TS_VERSION}.tar.gz && \
  rm v${NGINX_TS_VERSION}.tar.gz

# compile nginx
WORKDIR /src/nginx-${NGINX_VERSION}
RUN set -x && \
  ./configure --with-http_ssl_module \
  --add-module=/src/nginx-ts-module-${NGINX_TS_VERSION} \
  --with-http_stub_status_module \
  --conf-path=/config/nginx.conf \
  --error-log-path=/logs/error.log \
  --http-log-path=/logs/access.log && \
  make && \
  make install

# Copy NGINX config
COPY nginx.conf /config/nginx.conf

EXPOSE 8080


WORKDIR /
CMD "nginx"
