#!/bin/bash

### version 1.0
### last modified 28.08.2024
###

### vars
###
###
dir=/etc/opendkim/keys
keytable=/etc/opendkim/KeyTable

if [[ "$1" =~ ^[a-z-]+\.[a-z-]{2,}$ ]]; then

    opendkim-genkey --domain=$1 --bits=2048 --restrict --selector=default --directory=/etc/opendkim/keys/

    mv -f $dir/default.private $dir/$1.private
    mv -f $dir/default.txt $dir/$1.txt

    chown opendkim:opendkim $dir/$1.txt $dir/$1.private

    # Check if the domain already exists in the KeyTable file
    if ! grep -q "^default._domainkey.$1 " $keytable; then
        echo "default._domainkey.$1 $1:default:$dir/$1.private" >>$keytable
    else
        echo "Eintrag für $1 existiert bereits in der KeyTable."
    fi

    systemctl reload opendkim

else

    echo "Format: domainame.tld"

fi

exit 0
