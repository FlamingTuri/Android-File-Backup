#!/bin/bash

function usage {
    script_name="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
    echo "usage: ./$script_name [Options] {android backup folder/zip}"
    echo " -h    shows this help message"
    echo " -d directory    changes the directory (default /home/$USER/Desktop) where platform tools will be saved"
    echo " -r    removes the platform-tools folder (where adb is stored) at the end of the process"
    echo "EXAMPLES:"
    echo "./$script_name /home/$USER/Desktop/Backup-DeviceName-yyyy-mm-dd"
    echo "./$script_name /home/$USER/Desktop/Backup-DeviceName-yyyy-mm-dd.zip"
    exit 1
}

# cd to the current script directoy
cd "$(dirname "$0")"

WORKING_DIR="/home/$USER/Desktop"

while getopts "hrzd:" opt; do
  case $opt in
    d)
      # changes the default working directory (where the adb-tools
      # will be downloaded)
      WORKING_DIR=$OPTARG
      ;;
    h)
      usage
      ;;
    r)
      REMOVE_ADB=true
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
# to parse, no backup has been passed to the script
if [ $# -lt $OPTIND ]
then
    usage
fi

function restore_backup {
    echo "$1"
    # if the pushed directory is already present on the smartphone they will be merged
    for file in "$1"/*; do
        # -- sync pushes only the files if they are a newer
        # than the ones already present on the smartphone
        $ADB push --sync -a "$file" /sdcard
    done
}

# downloads android platform tools
./utils/download-platform-tools.sh "$WORKING_DIR"

ADB_TOOLS_PATH=$(./utils/combine_paths.sh "$WORKING_DIR" platform-tools)
ADB="$ADB_TOOLS_PATH/adb"

echo "restoring your backup"
BACKUP=${@:$OPTIND}
BACKUP_TYPE="$(file "$BACKUP")"
if [[ "$BACKUP_TYPE" == "$BACKUP: directory" ]]; then
    restore_backup "$BACKUP"
elif [[ "$BACKUP_TYPE" =~ ^"$BACKUP: Zip archive data".*$ ]]; then
    # TODO
    echo "for some reason unpacking the zip and then pushing its content does not work"
    exit -1

    REMOVE_CREATING="s/^\s*creating:\s*//g"
    REMOVE_TRAILING_SLASH="s/(\/)*$//g"
    # -m1 returns only the first line which contains the text "creating:"
    UNZIPPED_FOLDER=$(unzip -d /tmp "$BACKUP" | grep -m1 'creating:' | sed -E $REMOVE_CREATING | sed -E $REMOVE_TRAILING_SLASH)
    restore_backup "$UNZIPPED_FOLDER"
    rm -rf "$UNZIPPED_FOLDER"
else
    echo "Selected backup type not supported"
    echo "$BACKUP_TYPE"
    exit -1
fi

# removes platform-tools if the flag -r was set
if [ -n "${REMOVE_ADB+set}" ]; then
    rm -rf "$ADB_TOOLS_PATH"
fi
