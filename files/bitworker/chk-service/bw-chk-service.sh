#!/bin/bash

### vars
###
###
MSG_ACHTUNG="\e[31m[ACHTUNG]\e[0m"
MSG_OK="\e[32m[OK]\e[0m"

### load library
###
###
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bw-chk-service-lib.sh"

### Start
###
###
case "$1" in
dev)
    STDIN="dev"
    chk_services
    #chk_kernel_panic
    echo ""
    ;;
prod)
    chk_services
    ;;
ex)
    STDIN="dev"
    chk_local_services
    ;;
*)
    echo "Invalid argument. Use 'dev' , 'prod' or 'ex'"
    exit 1
    ;;
esac
