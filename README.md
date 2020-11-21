# Android File Backup

This project is born to solve common problems when transferring files and folders from your Android device to your desktop environment:
- transfer big folders
- keep the files original modification date

## Prerequisites

You must have a Unix-like environment to run this program.

Since this program relies on `adb`, on your Android device you need to enable:
- USB debugging
- USB file transfer
- accept the dialog asking to trust your computer RSA fingerprint

**Optional**: you need to have installed `pv` to view the backup compression progress (`-z` option) 

```bash
sudo apt-get install pv
```

## Installing

There is no real installation, just run the `adb-backup.sh` script and follow its help message:

```
usage: ./adb-backup.sh [Options] {android folders to backup}
 -h    shows this help message
 -d directory    changes the directory (default /home/$USER/Desktop) where the backup will be saved
 -r    removes the platform-tools folder (where adb is stored) at the end of the process
 -z    zips the backup
```

### Examples

```bash
# backups the "Pictures" Android folder
./adb-backup.sh /sdcard/Pictures
# backups "DCIM", "Download" and "Pictures" Android folders
./adb-backup.sh /sdcard/DCIM /sdcard/Download /sdcard/Pictures
# backups "Pictures" Android folder, the backup is created in /home/$USER/Downloads
./adb-backup.sh -d /home/$USER/Downloads /sdcard/Pictures
```

The script's default working directory is `/home/$USER/Desktop`. This is the directory where the `platform-tools` and the backup will be saved. To change it use the `-d` flag:

```bash
# sets the working folder to "/home/$USER/Downloads" and backups the "Pictures" Android folder
./adb-backup.sh -d /home/$USER/Downloads /sdcard/Pictures
```

## Built With

- [Android Debug Bridge](https://developer.android.com/studio/command-line/adb) - Android command-line tool

## License

This project is licensed under the GNU License - see the [LICENSE.md](LICENSE.md) file for further details
