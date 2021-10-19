#!/bin/bash

VER="3.1.0"

cd $(dirname $0)
rm -f ./fioprotocol-*.deb ./fioprotocol-*.deb.asc ./fioprotocol-*.tgz ./fioprotocol-*.tgz.asc

# Start with the full debian package
pushd deb >/dev/null
chmod 0755 ./fio/usr/local/bin/*

if [ ! -f fio/usr/local/bin/fio-nodeos ] ; then
	echo " *** ERROR *** binaries are missing, copy compiled files to:"
        echo "  ./deb/fio/usr/local/bin/fio-nodeos"
        echo "  ./deb/fio/usr/local/bin/clio"
        echo "  ./deb/fio/usr/local/bin/fio-wallet "
	exit 1
fi

NOW=$(date -u +%Y%m%d%H%M)

rm -f fio.deb
sed -i ".bak" "s/xxxxxxxxxxxx/$VER-$NOW/" fio/DEBIAN/control
dpkg-deb --build --root-owner-group fio
mv fio/DEBIAN/control.bak fio/DEBIAN/control
mv fio.deb ../fioprotocol-$VER-ubuntu-18.04-amd64.deb

# now the tarball and minimal package, which are almost the same thing.
pushd ../deb-minimal >/dev/null
mkdir -p fio-minimal/usr/opt/fio/${VER}/bin/ fio-minimal/usr/opt/fio/${VER}/license/ fio-minimal/usr/bin/
cp ../deb/fio/usr/local/bin/* fio-minimal/usr/opt/fio/${VER}/bin/

pushd fio-minimal/usr/opt/fio/${VER}/bin/ >/dev/null
rm -f fio-nodeos-run fioreq fiotop
mv fio-nodeos nodeos
pushd ../../..
tar czf ../../../../fioprotocol-"${VER}"-ubuntu-18.04-amd64.tgz fio/
popd >/dev/null
popd >/dev/null

cp ../deb/fio/usr/local/share/fio/LICENSE* fio-minimal/usr/opt/fio/${VER}/license/
pushd fio-minimal/usr/bin/ >/dev/null
ln -s ../opt/fio/${VER}/bin/* .
popd >/dev/null

sed -i ".bak" "s/xxxxxxxxxxxx/$NOW/" fio-minimal/DEBIAN/control
dpkg-deb --build --root-owner-group fio-minimal
mv fio-minimal/DEBIAN/control.bak fio-minimal/DEBIAN/control
mv fio-minimal.deb ../fioprotocol-minimal-$VER-ubuntu-18.04-amd64.deb
rm -fr fio-minimal/usr

