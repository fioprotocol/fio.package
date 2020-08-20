#!/bin/bash

chmod 0755 ./fio/usr/local/bin/*
rm -f ./fioprotocol-*.deb
rm -f ./fioprotocol-*.deb.asc

if [ ! -f fio/usr/local/bin/fio-nodeos ] ; then
	echo " *** ERROR *** binaries are missing, copy compiled files to:"
        echo "  ./fio/usr/local/bin/fio-nodeos"
        echo "  ./fio/usr/local/bin/clio"
        echo "  ./fio/usr/local/bin/fio-keosd "
	exit 1
fi

#VER="1.1.0-$(date -u +%Y%m%d%H%M)"
NOW=$(date -u +%Y%m%d%H%M)
VER="2.0.0"

rm -f fio.deb
sed -i ".bak" "s/xxxxxxxxxxxx/$NOW/" fio/DEBIAN/control
dpkg-deb --build --root-owner-group fio
mv fio.deb fioprotocol-$VER-ubuntu-18.04-amd64.deb
sed -i ".bak" "s/$NOW/xxxxxxxxxxxx/" fio/DEBIAN/control
