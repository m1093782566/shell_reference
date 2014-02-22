#!/usr/bin/env bash
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p484.tar.gz
tar xzvf ./ruby-1.9.3-p484.tar.gz
cd ./ruby-1.9.3-p484
./configure --prefix=/usr/local --enable-shared --disable-install-doc --with-opt-dir=/usr/local/lib
make
make install
