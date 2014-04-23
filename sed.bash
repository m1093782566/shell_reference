#/bin/bash

echo "#listen_tcp = 1" | sed '/listen/s/#//g'
listen_tcp = 1

echo "#listen_tcp = 1" | sed '/listen/s/1/0/g'
#listen_tcp = 0

echo "#listen_tcp" | sed 's/#listen_tcp/& = 1/g'
#listen_tcp = 1

echo 'libvirtd_opts="-d"' | sed 's/libvirtd_opts="-d/& -l/g'
libvirtd_opts="-d -l"

echo 'tcp_port = "16059"' | sed '/tcp_port/s/16059/16509/g'
tcp_port = "16509"
