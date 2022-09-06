# fio.package

These are build scripts for creating distributable packages for the fio protocol.

No binaries are kept here, they should be copied to the locations below before building:

```
./deb/fio/usr/local/bin/fio-nodeos
./deb/fio/usr/local/bin/fio-wallet
./deb/fio/usr/local/bin/clio
```

## Minimal Ubuntu package "fioprotocol-minimal-x.x.x-ubuntu-18.04-amd64.deb"

This is a minimal installation, that closely mimics the original Block one packages. Specifying dependencies,
putting each version into a distinct directory in /usr/opt/fio and attempts to create symlinks, resulting in
a structure roughly like the following:

```/usr/opt/fio/3.4.0/bin/clio
   /usr/opt/fio/3.4.0/bin/fio-wallet
   /usr/opt/fio/3.4.0/bin/nodeos
   /usr/opt/fio/3.4.0/license/
   /usr/opt/fio/3.4.0/license/LICENSE
   /usr/opt/fio/3.4.0/license/LICENSE.eosio
   /usr/opt/fio/3.4.0/license/LICENSE.go
   /usr/opt/fio/3.4.0/license/LICENSE.secp256k1
   /usr/opt/fio/3.4.0/license/LICENSE.softfloat
   /usr/opt/fio/3.4.0/license/LICENSE.wabt
   /usr/opt/fio/3.4.0/license/LICENSE.wavm
   /usr/opt/fio/3.4.0/license/LICENSE.yubihsm
   /usr/bin/clio -> ../opt/fio/3.4.0/bin/clio
   /usr/bin/fio-wallet -> ../opt/fio/3.4.0/bin/fio-wallet
   /usr/bin/nodeos -> ../opt/fio/3.4.0/bin/nodeos
```

## Tarball

The generated gzipped tar file contains the files from the minimal package, with the "fio" directory as the root.

## Full Ubuntu package "fioprotocol-x.x.x-ubuntu-18.04-amd64.deb"

This builds a .deb for Ubuntu 18 for quickly bringing up a FIO node. By default it will connect to mainnet, see
`/etc/fio/nodeos/` for testnet genesis.json and config.ini files.

### Building:

 * Update the version string in build.sh
 * `dpkg` must be installed (either use a debian-derived Linux, or on a Mac: `brew install dpkg`)
 * Once the binaries are in place, run `bash ./build.sh` and it will create the files.

### Distribution:

For distribution the package should be uploaded to the [FIO Releases page](https://github.com/fioprotocol/fio/releases) on GitHub as well as to the FIO S3 bucket noted below.

### Quick install instructions:

```
wget https://bin.fioprotocol.io/mainnet/fioprotocol-3.4.x-latest-ubuntu-18.04-amd64.deb
sudo apt-get install ./fioprotocol-3.4.x-latest-ubuntu-18.04-amd64.deb
sudo systemctl enable fio-nodeos.service
sudo systemctl start fio-nodeos.service
tail -f /var/log/fio/nodeos.log
```
