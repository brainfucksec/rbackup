```

########  ########     ###     ######  ##    ## ##     ## ########
##     ## ##     ##   ## ##   ##    ## ##   ##  ##     ## ##     ##
##     ## ##     ##  ##   ##  ##       ##  ##   ##     ## ##     ##
########  ########  ##     ## ##       #####    ##     ## ########
##   ##   ##     ## ######### ##       ##  ##   ##     ## ##
##    ##  ##     ## ##     ## ##    ## ##   ##  ##     ## ##
##     ## ########  ##     ##  ######  ##    ##  #######  ##

```

Shell script to make encrypted backups with rsync and GnuPG.

## Install
```bash
git clone https://github.com/brainfucksec/rbackup
cd rbackup
chmod +x install.sh
./install.sh
```

## Configuration
To encrypt your backups you need a valid [gpg key](https://www.gnupg.org/gph/en/manual/c14.html#AEN25)

Edit file `~/.config/rbackup/config` with your settings for backups, this file is widely commented.

Edit file `~/.config/rbackup/excluderc` with the directories and files to be excluded from the backup.

## Usage
Start backup:
```bash
rbackup --start
```

Show help menù:
```bash
rbackup --help
```

You can use crontab for periodic backups.

## References:

* [rsync Official Website](https://rsync.samba.org/)

* [rsync - Linux Man Page](https://linux.die.net/man/1/rsync)

* [GnuPG Official Website](https://gnupg.org/)

* [Linux crontab Command Help and Examples](https://www.computerhope.com/unix/ucrontab.htm)
