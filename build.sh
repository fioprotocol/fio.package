#!/usr/bin/env bash
#set -x

# Dev Notes
# redirect stderr to bit bucket: 2>/dev/null
# redirect both stdout and stderr to bit bucket: >/dev/null 2>&1
#
# Negating and grouping multiple conditionals
# Method #1
#  if ! { [ -x  ~/fio/3.5/bin/nodeos ] && [ -x ~/fio/3.5/bin/fio-wallet ] && [ -x ~/fio/3.5/bin/clio ]; }; then echo failure; fi
# Method #2
#  if ! [ -x  ~/fio/3.5/bin/nodeos -a -x ~/fio/3.5/bin/fio-wallet -a -x ~/fio/3.5/bin/clio ]; then
#
# View contents of packages
# Use dpkg-deb -c <deb file> to view the contents of a debian package
# Use tar -tvf <tar gzip file> to view the contents of a .tar.gz, .tgz

function wait_on {
  echo -n "Press any key to continue.."
  while [ true ]; do
    read -t 3 -n 1
    if [[ $? = 0 ]]; then
      break;
    fi
  done
}

BIN_DIR="$1"
BIN_DIR="${BIN_DIR/#\~/$HOME}"
if [[ -z "${BIN_DIR}" ]]; then
  echo "ERROR: No argument provided for location of fio binaries!"
  echo "  Usage: ./build.sh <BINARY DIRECTORY>"
  echo "  Example: ./build.sh /projects/fio/build/bin"
  echo "  Example: ./build.sh /install/fio/bin"
  exit 1
fi

# Verify files exist
if ! [ -x  "${BIN_DIR}"/nodeos -a -x "${BIN_DIR}"/fio-wallet -a -x "${BIN_DIR}"/clio ]; then
  echo " **************** ERROR ****************"
  echo " One or more FIO build artifacts are missing!"
  echo " - nodeos (nodeos -> fio-nodeos)"
  echo " - clio"
  echo " - fio-wallet"
  exit 1
fi

# Get version from nodeos binary and verify is as expected
VER=$($BIN_DIR/nodeos --version)
VER="${VER#v*}"
if [[ -z "${VER}" ]]; then
  echo "ERROR: Unable to determine VERSION from nodeos binary! Unable to proceed - exiting..."
  exit 1
fi
echo -n "Building packages for FIO version ${VER}. "
wait_on

# Clean any package bin artifacts
find ./deb/fio/usr/local/bin -maxdepth 1 -type f -not -name "*run" -delete

# Copy fio binaries from project bin directory (build/local install) into package bin dir
cp "${BIN_DIR}"/nodeos ./deb/fio/usr/local/bin/fio-nodeos
cp "${BIN_DIR}"/clio ./deb/fio/usr/local/bin/
cp "${BIN_DIR}"/fio-wallet ./deb/fio/usr/local/bin/

# Init constants
DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
NOW=$(date -u +%Y%m%d%H%M)

mkdir -p ${DIR}/dist
rm -f ${DIR}/dist/fioprotocol-${VER}-*.deb ${DIR}/dist/fioprotocol-${VER}-*.deb.asc ${DIR}/dist/fioprotocol-${VER}-*.tgz\
 ${DIR}/dist/fioprotocol-${VER}-*.tgz.asc ${DIR}/dist/checksums_${VER}.out

# Start with the full debian package
pushd deb >/dev/null
chmod 0755 ./fio/usr/local/bin/*

# Clean any previously generated package deb
rm -f fio.deb

# Create the control file from the template
sed "s/xxxxxxxxxxxx/${VER}/; s/tttttttttttt/${NOW}/;" ${DIR}/template/control.fio > fio/DEBIAN/control

# Package up a full install of fio
echo
dpkg-deb --build --root-owner-group fio 2>/dev/null
if [[ $? -ne 0 ]]; then
  echo "ERROR: unable to create fio package using dpkg-deb! Exiting..."
  exit 1
fi

mv fio.deb ${DIR}/dist/fioprotocol-${VER}-ubuntu-18.04-amd64.deb

# now the tarball and minimal package, which are very similar.
mkdir -p fio-minimal/usr/opt/fio/${VER}/bin/ fio-minimal/usr/opt/fio/${VER}/license/ fio-minimal/usr/bin/
cp ../deb/fio/usr/local/bin/* fio-minimal/usr/opt/fio/${VER}/bin/

# clean up some full install files
pushd fio-minimal/usr/opt/fio/${VER}/bin/ >/dev/null
rm -f fio-nodeos-run fioreq fiotop

# Return to ./deb
popd >/dev/null

# Copy the license files in for the tar gzip and fio-minimal packages
cp fio/usr/local/share/fio/LICENSE* fio-minimal/usr/opt/fio/${VER}/license/

# Now create the tar gzip
pushd fio-minimal/usr/opt >/dev/null
echo
tar czf ${DIR}/dist/fioprotocol-"${VER}"-ubuntu-18.04-amd64.tgz fio/ >/dev/null
if [[ $? -eq 0 ]]; then
  echo "TARBALL Contents: "
  tar -tvzf ${DIR}/dist/fioprotocol-"${VER}"-ubuntu-18.04-amd64.tgz
else
  echo "ERROR: unable to create fio-minimal package using dpkg-deb! Exiting..."
  exit 1
fi

# Return to the deb directory
popd >/dev/null

# Create the sym links for the fio-minimal package
pushd fio-minimal/usr/bin/ >/dev/null
ln -s ../opt/fio/${VER}/bin/* .

# Return to the deb directory
popd >/dev/null

# Create the control file from the template
mkdir -p fio-minimal/DEBIAN
sed "s/xxxxxxxxxxxx/${VER}/; s/tttttttttttt/${NOW}/;" ${DIR}/template/control.fio-minimal > fio-minimal/DEBIAN/control

# Clean any previously generated package debs
rm -f fio-minimal.deb

# Package up a minimal install of fio
echo
dpkg-deb --build --root-owner-group fio-minimal 2>/dev/null
if [[ $? -ne 0 ]]; then
  echo "ERROR: unable to create fio-minimal package using dpkg-deb! Exiting..."
  exit 1
fi

# Move to dist
mv fio-minimal.deb ${DIR}/dist/fioprotocol-minimal-${VER}-ubuntu-18.04-amd64.deb

# Clean up the fio and fio-minimal directory structure
rm fio/usr/local/bin/fio-nodeos
rm fio/usr/local/bin/clio
rm fio/usr/local/bin/fio-wallet
rm fio/DEBIAN/control

rm -rf fio-minimal/DEBIAN
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