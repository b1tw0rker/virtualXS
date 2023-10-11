#!/bin/bash

if [[ "$1" =~ ^[a-z]+\.[a-z]{2,}$ ]]; then
    pdnsutil delete-zone "$1"
else
    echo "Format: domainame.tld"
fi

exit 0
