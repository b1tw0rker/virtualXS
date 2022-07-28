#!/bin/bash

if [ "$1" != "" ]; then

    opendkim-genkey -d $1 -b 2048 -r -s $1
    chown opendkim:opendkim $1.txt $1.private

else

    echo "Missing domain (Format: domain.de)"

fi

exit 0
