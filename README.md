# fio.package

Creates the distributable packages for the fio protocol.

This builds deb packages as well as tarball of the FIO blockchain binaries including fio-nodeos, fio-wallet and clio. These packages provide a quick and straightforward process to stand up a FIO node. By default, fio-nodeos is configured to connect to 'mainnet', however, the 'testnet' configuration is also provided. See `/etc/fio/nodeos/` for the testnet genesis.json and config.ini files.

To execute, run `./build.sh`, providing the location of the fio binaries, i.e. /home/ubuntu/fio/bin. The build script will copy the binaries into ./deb and then create the packages. Note, the package will include the fio version, determined by executing `nodeos --version`

## Package Types
### Full Ubuntu package "fioprotocol-x.x.x-ubuntu-18.04-amd64.deb"
A full FIO installation, containing apparmor, logging, daemon and fio-nodeos configuration and binaries. It contains the following files;
```
/etc/apparmor.d/usr.local.bin.fio-nodeos
/etc/apparmor.d/usr.local.bin.fio-wallet
/etc/fio/nodeos/default-logging.json
/etc/fio/nodeos/genesis-mainnet.json
/etc/fio/nodeos/genesis-testnet.json
/etc/fio/nodeos/mainnet-config.ini
/etc/fio/nodeos/testnet-config.ini
/etc/logrotate.d/fio-nodeos
/etc/logrotate.d/fio-wallet
/lib/systemd/system/fio-nodeos.service
/lib/systemd/system/fio-wallet.service
/usr/local/bin/clio
/usr/local/bin/fio-nodeos
/usr/local/bin/fio-nodeos-run
/usr/local/bin/fio-wallet
/usr/local/share/fio/LICENSE.eosio
/usr/local/share/fio/LICENSE.go
/usr/local/share/fio/LICENSE.secp256k1
/usr/local/share/fio/LICENSE.softfloat
/usr/local/share/fio/LICENSE.wabt
/usr/local/share/fio/LICENSE.wavm
/usr/local/share/fio/LICENSE.yubihsm
/usr/local/share/fio/README
/var/lib/fio/fio-wallet/config.ini
/var/log/fio/nodeos.log
```

### Minimal Ubuntu package "fioprotocol-minimal-x.x.x-ubuntu-18.04-amd64.deb"
The minimal installation, closely resembling the original Block.one package install, contains the following files;
a structure as follows:
```/usr/opt/fio/3.5.0/bin/clio
   /usr/opt/fio/3.5.0/bin/fio-wallet
   /usr/opt/fio/3.5.0/bin/nodeos
   /usr/opt/fio/3.5.0/license/LICENSE
   /usr/opt/fio/3.5.0/license/LICENSE.eosio
   /usr/opt/fio/3.5.0/license/LICENSE.go
   /usr/opt/fio/3.5.0/license/LICENSE.secp256k1
   /usr/opt/fio/3.5.0/license/LICENSE.softfloat
   /usr/opt/fio/3.5.0/license/LICENSE.wabt
   /usr/opt/fio/3.5.0/license/LICENSE.wavm
   /usr/opt/fio/3.5.0/license/LICENSE.yubihsm
   /usr/bin/clio -> ../opt/fio/3.5.0/bin/clio
   /usr/bin/fio-wallet -> ../opt/fio/3.5.0/bin/fio-wallet
   /usr/bin/nodeos -> ../opt/fio/3.5.0/bin/nodeos
```

### Tarball
The gzipped tar file, also a minimal installation, contains the following files;
```fio/3.5.0/bin/clio
   fio/3.5.0/bin/fio-wallet
   fio/3.5.0/bin/nodeos
   fio/3.5.0/license/LICENSE
   fio/3.5.0/license/LICENSE.eosio
   fio/3.5.0/license/LICENSE.go
   fio/3.5.0/license/LICENSE.secp256k1
   fio/3.5.0/license/LICENSE.softfloat
   fio/3.5.0/license/LICENSE.wabt
   fio/3.5.0/license/LICENSE.wavm
   fio/3.5.0/license/LICENSE.yubihsm
```

### Build Notes:

 * `dpkg` must be installed (either use a debian-derived Linux, or in IOS: `brew install dpkg`)
 * Run `./build.sh <BINARY DIRECTORY>`, replacing \<BINARY DIRECTORY\> with the location of the fio binaries.

### Distribution:

For distribution the package should be uploaded to the [FIO Releases page](https://github.com/fioprotocol/fio/releases) on GitHub as well as to the FIO S3 bucket noted below.

### Install:
See https://dev.fio.net/docs/installation-using-packages for package installation instructions.
