#!/bin/bash

# usage: ./download-platform-tools.sh "/absolute/path/where/are/platform-tools"
# description: downloads android platform-tools if missing

# cd to the current script directoy
cd "$(dirname "$0")"

if [ $# -ne 1 ]
then
    echo "Wrong arguments number, expected 1 got $#"
    exit -1
fi

DOWNLOAD_DIR=$1
ADB_TOOLS_PATH=$(./combine_paths.sh "$DOWNLOAD_DIR" platform-tools)

# downloads latest platform-tools if missing
if [ ! -d "$ADB_TOOLS_PATH" ]
then
    TMPFILE="$(mktemp)"
    ADBURL="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"

    echo "downloading latest platform tools"
    wget $ADBURL -O "$TMPFILE"
    unzip -d "$DOWNLOAD_DIR" "$TMPFILE"
    rm "$TMPFILE"
fi
