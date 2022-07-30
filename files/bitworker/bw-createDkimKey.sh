#!/bin/bash

### vars
###
###

dir=/etc/opendkim/keys

if [ "$1" != "" ]; then

    opendkim-genkey --domain=$1 --bits=2048 --restrict --selector=default --directory=/etc/opendkim/keys/

    mv -f $dir/default.private $dir/$1.private
    mv -f $dir/default.txt $dir/$1.txt

    chown opendkim:opendkim $dir/$1.txt $dir/$1.private

    systemctl reload opendkim

else

    echo "Domain (Format: domain.de) fehlt"

fi

exit 0
