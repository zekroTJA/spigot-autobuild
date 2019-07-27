
CYAN="\033[0;36m" 
PURPLE="\033[0;35m"
RESET="\033[0m"

function is_true {
    if [ "$1" == "true" ] ||\
        [ "$1" == "t" ] ||\
        [ "$1" == "TRUE" ] ||\
        [ "$1" == "T" ] ||\
        [ "$1" == "1" ]; then
        return 0
    fi
    return 1
}