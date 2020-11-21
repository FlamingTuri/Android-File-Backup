# combines two paths: P1, P2 => P1/P2
function combine_paths {
    if [[ "$1" == */ ]] && [[ "$2" == /* ]]
    then
        combine_result="$1${2:1}"
    elif [[ "$1" == */ ]] || [[ "$2" == /* ]]
    then
        combine_result="$1$2"
    else
        combine_result="$1/$2"
    fi
    echo $combine_result
}

combine_paths "$1" "$2"
