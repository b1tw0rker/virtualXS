#!/bin/bash

if [ "$1" != "" ] && [[ "$1" == *.* && "$1" != *.*.* ]]; then
    # Extrahiere den Teil nach dem letzten Punkt im Domainnamen
    after_dot="${1##*.}"

    # Überprüfe, ob der Teil nach dem Punkt mindestens zwei Buchstaben von a-z enthält
    if [[ "$after_dot" =~ ^[a-z]{2,}$ ]]; then
        pdns_control notify "$1"
    else
        echo "Der Domainname nach dem Punkt muss mindestens zwei Buchstaben von a-z enthalten."
    fi
else
    echo "Domainname (ohne www) fehlt oder enthält nicht genau einen Punkt."
fi

exit 0
