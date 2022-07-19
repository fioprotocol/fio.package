#!/usr/bin/env bash

VER="3.4.0-rc1"

DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

mkdir -p $DIR/dist
rm -f $DIR/dist/fioprotocol-*.deb $DIR/dist/fioprotocol-*.deb.asc $DIR/dist/fioprotocol-*.tgz\
 $DIR/dist/fioprotocol-*.tgz.asc $DIR/dist/md5.out $DIR/dist/sha256.out

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

# redirect stderr to bit bucket: 2>/dev/null
# redirect both stdout and stderr to bit bucket: >/dev/null 2>&1
rm -f fio.deb
sed -i".bak" "s/xxxxxxxxxxxx/$VER-$NOW/" fio/DEBIAN/control
echo
dpkg-deb --build --root-owner-group fio 2>/dev/null
if [[ $? -ne 0 ]]; then
  echo "ERROR: unable to create fio package using dpkg-deb! Exiting..."
  exit 1
fi
mv fio/DEBIAN/control.bak fio/DEBIAN/control
mv fio.deb $DIR/dist/fioprotocol-$VER-ubuntu-18.04-amd64.deb

# now the tarball and minimal package, which are almost the same thing.
pushd ../deb-minimal >/dev/null
mkdir -p fio-minimal/usr/opt/fio/${VER}/bin/ fio-minimal/usr/opt/fio/${VER}/license/ fio-minimal/usr/bin/
cp ../deb/fio/usr/local/bin/* fio-minimal/usr/opt/fio/${VER}/bin/

pushd fio-minimal/usr/opt/fio/${VER}/bin/ >/dev/null
rm -f fio-nodeos-run fioreq fiotop
mv fio-nodeos nodeos

pushd ../../.. >/dev/null
echo
tar czf $DIR/dist/fioprotocol-"${VER}"-ubuntu-18.04-amd64.tgz fio/ >/dev/null
if [[ $? -eq 0 ]]; then
  echo "TARBALL Contents: "
  tar -tvzf $DIR/dist/fioprotocol-"${VER}"-ubuntu-18.04-amd64.tgz
else
  echo "ERROR: unable to create fio-minimal package using dpkg-deb! Exiting..."
  exit 1
fi

popd >/dev/null
popd >/dev/null

cp ../deb/fio/usr/local/share/fio/LICENSE* fio-minimal/usr/opt/fio/${VER}/license/
pushd fio-minimal/usr/bin/ >/dev/null
ln -s ../opt/fio/${VER}/bin/* .
popd >/dev/null

sed -i".bak" "s/xxxxxxxxxxxx/$NOW/" fio-minimal/DEBIAN/control
echo
dpkg-deb --build --root-owner-group fio-minimal 2>/dev/null
if [[ $? -ne 0 ]]; then
  echo "ERROR: unable to create fio-minimal package using dpkg-deb! Exiting..."
  exit 1
fi
mv fio-minimal/DEBIAN/control.bak fio-minimal/DEBIAN/control
mv fio-minimal.deb $DIR/dist/fioprotocol-minimal-$VER-ubuntu-18.04-amd64.deb
rm -rf fio-minimal/usr

pushd -0 >/dev/null && dirs -c
pushd dist >/dev/null
echo
echo "MD5 CheckSum:"
md5sum fioprotocol-$VER-ubuntu-18.04-amd64.deb fioprotocol-minimal-$VER-ubuntu-18.04-amd64.deb\
 fioprotocol-"${VER}"-ubuntu-18.04-amd64.tgz | tee $DIR/dist/md5.out
echo
echo "SHA-256 CheckSum:"
sha256sum fioprotocol-$VER-ubuntu-18.04-amd64.deb fioprotocol-minimal-$VER-ubuntu-18.04-amd64.deb\
 fioprotocol-"${VER}"-ubuntu-18.04-amd64.tgz | tee $DIR/dist/sha256.out
echo

#NOW=$(date +"%Y%m%d-%H%M%S")
zip fioprotocol_"${VER}_${NOW}".zip fioprotocol* md5.out sha256.out >/dev/null
popd >/dev/null
