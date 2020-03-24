#!/bin/bash

if [ ! -f fio/usr/local/bin/fio-nodeos ] ; then
	echo " *** ERROR *** binaries are missing, copy compiled files to:"
        echo "  ./fio/usr/local/bin/fio-nodeos"
        echo "  ./fio/usr/local/bin/fio-keosd "
        echo "  ./fio/usr/local/bin/clio "
	exit 1
fi

VER=$(date +%Y%m%d%H%M)

rm -f fio.deb
sed -i ".bak" "s/xxxxxxxxxxxx/$VER/" fio/DEBIAN/control
dpkg-deb --build --root-owner-group fio
mv fio.deb fioprotocol-1.0.x-$VER-ubuntu-18.04-amd64.deb
sed -i ".bak" "s/$VER/xxxxxxxxxxxx/" fio/DEBIAN/control

