#!/bin/bash
#install go 1.2.1 linux amd64
wget https://go.googlecode.com/files/go1.2.1.linux-amd64.tar.gz
mv go1.2.1.linux-amd64.tar.gz /usr/local
tar -C /usr/local -xzf go1.2.1.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
