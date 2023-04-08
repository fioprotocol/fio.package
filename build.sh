#!/usr/bin/env bash
set -x
VER="$1"
if [[ -z "${VER}" ]]; then
  echo "ERROR: No argument provided for Version!"
  echo "  Usage: ./build.sh 3.4.0"
  exit 1
fi

DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

mkdir -p ${DIR}/dist
rm -f ${DIR}/dist/fioprotocol-${VER}-*.deb ${DIR}/dist/fioprotocol-${VER}-*.deb.asc ${DIR}/dist/fioprotocol-${VER}-*.tgz\
 ${DIR}/dist/fioprotocol-${VER}-*.tgz.asc ${DIR}/dist/checksums_${VER}.out

# Start with the full debian package
pushd deb >/dev/null
chmod 0755 ./fio/usr/local/bin/*

if [ ! -f fio/usr/local/bin/fio-nodeos ] ; then
  echo " **************** ERROR ****************"
  echo " The FIO build artifacts are missing!"
  echo " - Copy the following FIO ${VER} binaries to ./deb/fio/usr/local/bin"
  echo "   - fio-nodeos (nodeos -> fio-nodeos)"
  echo "   - clio"
  echo "   - fio-wallet"
  exit 1
fi

NOW=$(date -u +%Y%m%d%H%M)

# redirect stderr to bit bucket: 2>/dev/null
# redirect both stdout and stderr to bit bucket: >/dev/null 2>&1
rm -f fio.deb
sed "s/xxxxxxxxxxxx/${VER}/; s/tttttttttttt/${NOW}/;" ${DIR}/template/control.fio > fio/DEBIAN/control

echo
dpkg-deb --build --root-owner-group fio 2>/dev/null
if [[ $? -ne 0 ]]; then
  echo "ERROR: unable to create fio package using dpkg-deb! Exiting..."
  exit 1
fi

rm fio/DEBIAN/control
mv fio.deb ${DIR}/dist/fioprotocol-${VER}-ubuntu-18.04-amd64.deb

# now the tarball and minimal package, which are almost the same thing.
pushd ../deb-minimal >/dev/null
mkdir -p fio-minimal/usr/opt/fio/${VER}/bin/ fio-minimal/usr/opt/fio/${VER}/license/ fio-minimal/usr/bin/
cp ../deb/fio/usr/local/bin/* fio-minimal/usr/opt/fio/${VER}/bin/

pushd fio-minimal/usr/opt/fio/${VER}/bin/ >/dev/null
rm -f fio-nodeos-run fioreq fiotop
mv fio-nodeos nodeos

pushd ../../.. >/dev/null
echo
tar czf ${DIR}/dist/fioprotocol-"${VER}"-ubuntu-18.04-amd64.tgz fio/ >/dev/null
if [[ $? -eq 0 ]]; then
  echo "TARBALL Contents: "
  tar -tvzf ${DIR}/dist/fioprotocol-"${VER}"-ubuntu-18.04-amd64.tgz
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

sed "s/xxxxxxxxxxxx/${VER}/; s/tttttttttttt/${NOW}/;" ${DIR}/template/control.fio-minimal > fio-minimal/DEBIAN/control

echo
dpkg-deb --build --root-owner-group fio-minimal 2>/dev/null
if [[ $? -ne 0 ]]; then
  echo "ERROR: unable to create fio-minimal package using dpkg-deb! Exiting..."
  exit 1
fi

rm fio-minimal/DEBIAN/control
mv fio-minimal.deb ${DIR}/dist/fioprotocol-minimal-${VER}-ubuntu-18.04-amd64.deb
rm -rf fio-minimal/usr

pushd -0 >/dev/null && dirs -c
pushd dist >/dev/null
md5checksums=$(md5sum fioprotocol-${VER}-ubuntu-18.04-amd64.deb fioprotocol-minimal-${VER}-ubuntu-18.04-amd64.deb\
 fioprotocol-"${VER}"-ubuntu-18.04-amd64.tgz | tee -a ${DIR}/dist/checksums_${VER}.out)
echo
echo "# Checksums"
echo "## MD5 (`md5sum --version | grep md5sum`)"
IFS=$' \n' read -r -d '' -a arr < <(printf '%s\0' "$md5checksums"); declare -a arr
length=${#arr[@]}
for (( j=0; j<=${length}-2; j=j+2 ));
do
  echo "${arr[$j+1]}  ${arr[$j]}"
done

sha256checksums=$(sha256sum fioprotocol-${VER}-ubuntu-18.04-amd64.deb fioprotocol-minimal-${VER}-ubuntu-18.04-amd64.deb\
 fioprotocol-"${VER}"-ubuntu-18.04-amd64.tgz)
echo
echo "## SHA-256 (`sha256sum --version | grep sha256sum`)"
IFS=$' \n' read -r -d '' -a arr < <(printf '%s\0' "$sha256checksums"); declare -a arr
for (( j=0; j<=${length}-2; j=j+2 ));
do
  echo "${arr[$j+1]}  ${arr[$j]}"
done

echo
echo "Pretty-print for Release Notes..."
echo | tee ${DIR}/dist/checksums_${VER}.out
echo "# Checksums" | tee -a ${DIR}/dist/checksums_${VER}.out
echo "## MD5 (`md5sum --version | grep md5sum`)" | tee -a ${DIR}/dist/checksums_${VER}.out
IFS=$' \n' read -r -d '' -a arr < <(printf '%s\0' "$md5checksums"); declare -a arr
length=${#arr[@]}
echo '| File | Checksum |' | tee -a ${DIR}/dist/checksums_${VER}.out
echo '| ---- | -------- |' | tee -a ${DIR}/dist/checksums_${VER}.out
for (( j=0; j<=${length}-2; j=j+2 ));
do
  echo "|${arr[$j+1]}|${arr[$j]}|" | tee -a ${DIR}/dist/checksums_${VER}.out
done
echo | tee -a ${DIR}/dist/checksums_${VER}.out

echo "## SHA-256 (`sha256sum --version | grep sha256sum`)" | tee -a ${DIR}/dist/checksums_${VER}.out
IFS=$' \n' read -r -d '' -a arr < <(printf '%s\0' "$sha256checksums"); declare -a arr
length=${#arr[@]}
echo '| File | Checksum |' | tee -a ${DIR}/dist/checksums_${VER}.out
echo '| ---- | -------- |' | tee -a ${DIR}/dist/checksums_${VER}.out
for (( j=0; j<=${length}-2; j=j+2 ));
do
  echo "|${arr[$j+1]}|${arr[$j]}|" | tee -a ${DIR}/dist/checksums_${VER}.out
done
echo | tee -a ${DIR}/dist/checksums_${VER}.out

# Zip up this distro. Use timestamp for uniqueness.
zip fioprotocol_"${VER}_${NOW}".zip fioprotocol*${VER}* checksums_${VER}.out >/dev/null
popd >/dev/null
