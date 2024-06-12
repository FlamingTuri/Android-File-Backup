#!/bin/bash

# combines two paths: P1, P2 => P1/P2

if [ $# -ne 2 ]
then
    echo "Wrong arguments number, expected 2 got $#"
    exit -1
fi

if [[ "$1" == */ ]] && [[ "$2" == /* ]]
then
    combine_result="$1${2:1}"
elif [[ "$1" == */ ]] || [[ "$2" == /* ]]
then
    combine_result="$1$2"
else
    combine_result="$1/$2"
fi

echo "$combine_result"
