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

There is no real installation, just run `adb-backup.sh` or `adb-restore.sh` and tune them according to your needs:

[adb-backup.sh](src/adb-backup.sh)
```
usage: ./adb-backup.sh [Options] {android folders to backup}
 -h    shows this help message
 -d directory    changes the directory (default /home/$USER/Desktop) where platform-tools and the backup will be saved
 -r    removes the platform-tools folder (where adb is stored) at the end of the process
 -z    zips the backup
```

[adb-restore.sh](src/adb-restore.sh)
```
usage: ./adb-restore.sh [Options] {android backup folder/zip}
 -h    shows this help message
 -d directory    changes the directory (default /home/gventurini/Desktop) where platform tools will be saved
 -r    removes the platform-tools folder (where adb is stored) at the end of the process
EXAMPLES:
./adb-restore.sh /home/gventurini/Desktop/Backup-DeviceName-yyyy-mm-dd
./adb-restore.sh /home/gventurini/Desktop/Backup-DeviceName-yyyy-mm-dd.zip
```

### Examples

```bash
# backups the "Pictures" Android folder
./adb-backup.sh /sdcard/Pictures
# backups "DCIM", "Download" and "Pictures" Android folders
./adb-backup.sh /sdcard/DCIM /sdcard/Download /sdcard/Pictures
# backups "Pictures" Android folder, the backup is created in /home/$USER/Downloads
./adb-backup.sh -d /home/$USER/Downloads /sdcard/Pictures

# restores a previous backup, content on the device that is not present in the backup won't be lost
./adb-restore.sh /home/$USER/Desktop/Backup-DeviceName-yyyy-mm-dd
```

## Built With

- [Android Debug Bridge](https://developer.android.com/studio/command-line/adb) - Android command-line tool

## License

This project is licensed under the GNU License - see the [LICENSE.md](LICENSE.md) file for further details
