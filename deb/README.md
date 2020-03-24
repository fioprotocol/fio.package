# FIO Protocol Ubuntu package

This builds a .deb for Ubuntu 18 for quickly bringing up a FIO node. By default it will connect to mainnet, see
`/etc/fio/nodeos/` for testnet genesis.json and config.ini files.

## Building:

 * `dpkg` must be installed (either use a debian-derived Linux, or on a Mac: `brew install dpkg`)
 * No binaries are kept here, they should be copied to the locations below before building:

```
fio/usr/local/bin/fio-nodeos
fio/usr/local/bin/fio-keosd
fio/usr/local/bin/clio
```

 * Once the binaries are in place, run `bash ./build.sh` and it will create a .deb in this directory.

## Distribution:

These are being uploaded to https://bin.fioprotocol.io/mainnet/fioprotocol-1.0.x-latest-ubuntu-18.04-amd64.deb, but
it's best to get them directly from the releases section in github.com/fioprotocol/fio

Quick install instructions:

```
wget https://bin.fioprotocol.io/mainnet/fioprotocol-1.0.x-latest-ubuntu-18.04-amd64.deb
sudo apt-get install ./fioprotocol-1.0.x-latest-ubuntu-18.04-amd64.deb
sudo systemctl enable fio-nodeos.service
sudo systemctl start fio-nodeos.service
tail -f /var/log/fio/nodeos.log
```

