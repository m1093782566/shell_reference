#!/bin/sh
route add default gw 10.10.101.254 dev eth0

ip  route flush table net_101 
ip  route add default via 10.10.101.254 dev eth0 src 10.10.101.105  table net_101 
ip  rule  add from 10.10.101.105 table net_101
ip  route flush table net_103
ip  route add default via 10.10.103.254 dev cloudbr0 src 10.10.103.110  table net_103 
ip  rule  add from 10.10.103.110 table net_103
