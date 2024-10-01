#!/bin/bash

if [[ "$1" =~ ^[a-z0-9-]+\.[a-z]{2,}$ ]]; then
    pdnsutil delete-zone "$1"
else
    echo "Format: domainname.tld"
fi

exit 0
