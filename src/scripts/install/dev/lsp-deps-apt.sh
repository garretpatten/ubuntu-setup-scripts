#!/bin/bash
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential \
  gzip \
  tar \
  curl \
  golang-go \
  ruby-full \
  ruby-dev \
  default-jdk-headless \
  php-cli \
  php-mbstring \
  php-xml \
  php-zip \
  composer \
  lua5.4 \
  liblua5.4-dev \
  luarocks

# Julia is not in all Ubuntu releases (e.g. ubuntu-latest); do not fail the batch above.
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y julia || true
