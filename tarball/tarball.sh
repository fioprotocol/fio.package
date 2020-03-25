#!/bin/bash

pushd $(dirname $0)
VER=v1.0.0
rm -fr ./fioprotocol/*
mkdir -p ./fioprotocol/${VER}/bin ./fioprotocol/${VER}/etc
cp ../deb/fio/usr/local/bin/clio ./fioprotocol/${VER}/bin/
cp ../deb/fio/usr/local/bin/fio-nodeos ./fioprotocol/${VER}/bin/nodeos
cp ../deb/fio/usr/local/bin/fio-keosd ./fioprotocol/${VER}/bin/keosd
cp $(find ../deb/fio/etc/fio/nodeos -type f -maxdepth 1) ./fioprotocol/${VER}/etc/

NOW=$(date +%Y%m%d%H%M)
tar czvf fioprotocol-"${VER}-${NOW}"-ubuntu-18.04-amd64.tgz fioprotocol/
gpg --detach-sign -a -u 0CFEE764B06D009F7574A253C0E61F8441B6AAD4 fioprotocol-"${VER}-${NOW}"-ubuntu-18.04-amd64.tgz


