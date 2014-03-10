#!/bin/bash
base_url="http://cloudstack.apt-get.eu/ubuntu/dists/precise/4.2/pool/cloudstack-"
version="_4.2.0_all.deb"
deltas=( common docs management usage )
for i in "${deltas[@]}"
do
    real_url=$base_url$i$version
    wget $real_url
done
