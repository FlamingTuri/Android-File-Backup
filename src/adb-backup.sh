#!/bin/bash

set -o errexit

function usage {
    script_name="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
    echo "usage: ./$script_name [Options] {android folders to backup}"
    echo " -h    shows this help message"
    echo " -d directory    changes the directory (default /home/$USER/Desktop) where platform-tools and the backup will be saved"
    echo " -r    removes the platform-tools folder (where adb is stored) at the end of the process"
    echo " -z    zips the backup"
    echo "EXAMPLES:"
    echo "./$script_name /sdcard/Pictures"
    echo "./$script_name /sdcard/DCIM /sdcard/Download /sdcard/Pictures"
    echo "./$script_name -d /home/$USER/Downloads /sdcard/Pictures"
    exit 1
}

# cd to the current script directoy
cd "$(dirname "$0")"

WORKING_DIR="/home/$USER/Desktop"

while getopts "hrzd:" opt; do
  case $opt in
    d)
      # changes the default working directory (where the adb-tools
      # will be downloaded and the backup will be saved)
      WORKING_DIR=$OPTARG
      ;;
    h)
      usage
      ;;
    r)
      REMOVE_ADB=true
      ;;
    z)
      ZIP=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument" >&2
      exit 1
      ;;
  esac
done

# if the inserted arguments number is less than the next index
# to parse, no folder to backup has been passed to the script
if [ $# -lt $OPTIND ]
then
    usage
fi

# downloads android platform tools
./utils/download-platform-tools.sh "$WORKING_DIR"

ADB_TOOLS_PATH=$(./utils/combine_paths.sh "$WORKING_DIR" platform-tools)
ADB="$ADB_TOOLS_PATH/adb"

# name of the backup folder
BCK_NAME=Backup-"$("$ADB" shell getprop ro.product.device)"-$(date +"%Y-%m-%d")

# backup directory absolute path $WORKING_DIR/$BCK_NAME
BCK_DIR=$(./utils/combine_paths.sh "$WORKING_DIR" "$BCK_NAME")

# creates the backup directory
mkdir "$BCK_DIR"

echo "copying files from your device"
# $OPTIND stores the next index to parse after all the flags
# (and their parameters) have been successfully evaluated
for android_directory in "${@:$OPTIND}"
do
    # -a preserves file timestamp and mode
    "$ADB" pull -a "$android_directory" "$BCK_DIR"
done

# recursively removes the transferred empty directories
./utils/remove-empty-directories.sh "$BCK_DIR"

# zips the backup directory
if [ -n "${ZIP+set}" ]; then
    echo "zipping your backup..."
    # cd $WORKING_DIR is necessary, using "$BCK_DIR" instead produces
    #  a zip with the same file structure of "$BCK_DIR" absolute path
    cd "$WORKING_DIR"

    # checks if pv is installed
    if command -v pv >/dev/null
    then
        # shows zip progress via pv
        zip -qrm - "$BCK_NAME" | pv -bep -s $(du -bs "$BCK_NAME" | awk '{print $1}') > "$BCK_NAME".zip
    else
        zip -qrm "$BCK_NAME".zip "$BCK_NAME"
    fi
fi

# removes platform-tools if the flag -r was set
if [ -n "${REMOVE_ADB+set}" ]; then
    rm -rf "$ADB_TOOLS_PATH"
fi
