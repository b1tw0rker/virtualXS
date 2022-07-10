#!/bin/bash
#    Version 1.3 - Stand 30.01.2022
#    (C) by Dipl. Wirt.-Ing. Nick Herrmann
#
#    This program is WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

FOLDER=/tmp/changer

###
###
###

if [ ! -d $FOLDER ]; then
        mkdir $FOLDER
fi

echo
while [ -z "$QUELLE" ]; do
        echo -n "Absoluten Pfad der Quelle eingeben, ohne ending slash (q fuer ENDE): "
        read QUELLE
        if [ $QUELLE = "q" ]; then
                exit 1
        fi
        if [ ! -d $QUELLE ]; then
                echo
                echo
                echo "$QUELLE ist kein Verzeichnis. Die Quelle muss ein Verzeichnis sein."
                echo
                exit 2
        fi
done
echo
while [ -z "$ALT" ]; do
        echo -n "Alter Wert: "
        read ALT
done
echo
while [ -z "$NEU" ]; do
        echo -n "Neuer Wert (Sonderzeichen mit Backslash (\): "
        read NEU
done
for i in $(grep -lr $ALT $QUELLE); do
        echo "DATEI $i wurde geaendert"
        DATEI=$(basename $i)
        PFAD=$(dirname $i)
        if [ -f $i ]; then
                sed s/$ALT/$NEU/g $i >$FOLDER/$DATEI
                mv $FOLDER/$DATEI $PFAD/$DATEI
        fi
done

### post work

echo -n "Temp Dir $FOLDER jetzt loeschen ? (y/n): "
read DELETE

if [ $DELETE = "Y" ] || [ $DELETE = "y" ]; then
        if [ -d $FOLDER ]; then
                rmdir $FOLDER
        fi
fi

exit
