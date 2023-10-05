#!/bin/bash

### Sources
### color formating: https://misc.flogisoft.com/bash/tip_colors_and_formatting
###
###

### Confirm function
### version 1.0.0
### last-modified: 01.10.23
###
confirm() {
    local prompt="$1"
    local default_value="$2"
    local result

    while true; do
        read -p "$prompt [y/N]: " -ei "$default_value" result
        case $result in
        [y]) return 0 ;; # return 0 bedeutet Erfolg bzw. "ja"
        [n]) return 1 ;; # return 1 bedeutet "nein"
        *) echo "Please enter only 'y' or 'n'." ;;
        esac
    done
}

### print centered some lines and write some infos
### https://superuser.com/questions/823883/how-to-justify-and-center-text-in-bash/829870
### version 1.0.0
### last-modified: 01.10.23
###
print_center() {
    local x
    local y
    text="$*"
    x=$((($(tput cols) - ${#text}) / 2))
    echo -ne "\E[6n"
    read -sdR y
    y=$(echo -ne "${y#*[}" | cut -d';' -f1)
    echo -ne "\033[${y};${x}f$*"
}
