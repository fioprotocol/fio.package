FIO packages:

Notes:

* This package is configured to connect to the FIO mainnet by default. If connecting to a different network,
  replace the /etc/fio/nodeos/genesis.json file, remove all files under /var/lib/fio/data/, and update the peers
  in /etc/fio/nodeos/config.ini
* Systemd units are installed, but none are enabled at install.
  The availble systemd units are: fio-keosd.service, and fio-nodeos.service
* Data is stored in /var/lib/fio
* Both nodeos and keosd run under restrictive apparmor profiles, and with additional seccomp rules (via systemd).
* Log rotation is configured.

Full list of file locations:

├── etc
│   ├── apparmor.d
│   │   ├── usr.local.bin.fio-keosd
│   │   └── usr.local.bin.fio-nodeos
│   ├── fio
│   │   └── nodeos
│   │       ├── config.ini
│   │       └── genesis.json
│   ├── logrotate.d
│   │   ├── fio-keosd
│   │   └── fio-nodeos
│   └── update-motd.d
│       └── 99-fio
├── lib
│   └── systemd
│       └── system
│           ├── fio-keosd.service
│           └── fio-nodeos.service
├── usr
│   └── local
│       ├── bin
│       │   ├── fio-keosd
│       │   ├── fio-nodeos
│       │   ├── clio
│       │   ├── fio-start-nodeos
│       │   ├── keosd -> fio-keosd
│       │   └── nodeos -> fio-nodeos
│       └── share
│           └── fio
│               └── README
└── var
    ├── lib
    │   └── fio
    │       ├── data
    │       └── eosio-wallet
    │           └── config.ini
    └── log
        └── fio

