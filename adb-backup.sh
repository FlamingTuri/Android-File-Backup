#!/bin/bash

function usage {
    echo "usage: ./adb-backup.sh [Options] {android folders to backup}"
    echo " -h    shows this help message"
    echo " -d directory    changes the directory (default /home/$USER/Desktop) where the backup will be saved"
    echo " -r    removes the platform-tools folder (where adb is stored) at the end of the process"
    echo " -z    zips the backup"
    echo "EXAMPLES:"
    echo "./adb-backup.sh /sdcard/Pictures"
    echo "./adb-backup.sh /sdcard/DCIM /sdcard/Download /sdcard/Pictures"
    echo "./adb-backup.sh -d /home/$USER/Downloads /sdcard/Pictures"
    exit 1
}

# combines two paths: P1, P2 => P1/P2
function combine_path {
    if [[ "$1" == */ ]] && [[ "$2" == /* ]]
    then
        combine_result="$1${2:1}"
    elif [[ "$1" == */ ]] || [[ "$2" == /* ]]
    then
        combine_result="$1$2"
    else
        combine_result="$1/$2"
    fi
}

# cd to the current script directoy
cd "$(dirname "$0")"

WORKING_DIR="/home/$USER/Desktop"
ADB_DIR=platform-tools

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

combine_path "$WORKING_DIR" "$ADB_DIR"
ADB_TOOLS_PATH="$combine_result"

# downloads latest platform-tools if missing
if [ ! -d "$ADB_TOOLS_PATH" ]
then
    TMPFILE=`mktemp`
    ADBURL="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"

    wget $ADBURL -O $TMPFILE
    unzip -d $WORKING_DIR $TMPFILE
    rm $TMPFILE
fi

ADB="$ADB_TOOLS_PATH/adb"

# creates the backup folder's name
BCK_NAME=Backup-$($ADB shell getprop ro.product.device)-$(date +"%Y-%m-%d")

# creates the backup directory absolute path
combine_path "$WORKING_DIR" "$BCK_NAME"
BCK_DIR="$combine_result" # $WORKING_DIR/$BCK_NAME

# creates the backup directory
mkdir "$BCK_DIR"

echo "copying files from your device"
# $OPTIND stores the next index to parse after all the flags
# (and their parameters) have been successfully evaluated
for android_directory in "${@:$OPTIND}"
do
    # -a preserves file timestamp and mode
    $ADB pull -a "$android_directory" "$BCK_DIR"
done

# recursively removes the transferred empty directories
./remove-empty-directories.sh "$BCK_DIR"

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
