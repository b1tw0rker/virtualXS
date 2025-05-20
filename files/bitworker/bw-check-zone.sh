#!/bin/bash

# Skript zur Anzeige von A-Records einer Domain mittels pdnsutil
# Autor: Claude
# Datum: 2025-05-20

# Hilfsfunktion
show_usage() {
    echo "Verwendung: $0 [domainname]"
    echo "  Zeigt die A-Records einer Domain auf dem lokalen PowerDNS Server an."
    echo ""
    echo "  Falls kein Domainname angegeben wird, wird interaktiv danach gefragt."
    exit 1
}

# Prüfe auf Hilfeaufruf
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
fi

# Domainname aus Parameter oder Eingabeaufforderung
DOMAIN=""
if [ -n "$1" ]; then
    DOMAIN="$1"
else
    echo -n "Bitte geben Sie den Domainnamen ein: "
    read DOMAIN
fi

# Prüfe, ob ein Domainname eingegeben wurde
if [ -z "$DOMAIN" ]; then
    echo "Fehler: Kein Domainname angegeben."
    show_usage
fi

# Prüfe, ob pdnsutil verfügbar ist
if ! command -v pdnsutil &> /dev/null; then
    echo "Fehler: pdnsutil ist nicht installiert oder nicht im PATH."
    exit 2
fi

echo "A-Records für $DOMAIN:"
echo "----------------------------------------"
# Prüfe zuerst, ob die Zone existiert
if ! pdnsutil list-all-zones | grep -q "^${DOMAIN}$"; then
    echo "Fehler: Die Zone '$DOMAIN' existiert nicht auf diesem Server."
    
    # Prüfe, ob eine ähnliche Zone existiert (z.B. .de statt .com)
    SIMILAR_DOMAINS=$(pdnsutil list-all-zones | grep -E "^$(echo $DOMAIN | cut -d. -f1)")
    if [ -n "$SIMILAR_DOMAINS" ]; then
        echo "Ähnliche Domains gefunden:"
        echo "$SIMILAR_DOMAINS"
        echo "Bitte versuchen Sie es mit einer dieser Domains."
    fi
    
    exit 3
fi

# Hole die A-Records
RECORDS=$(pdnsutil list-zone "$DOMAIN" 2>/dev/null | grep -E "IN\s+A")

# Prüfe ob A-Records gefunden wurden
if [ -z "$RECORDS" ]; then
    echo "Keine A-Records für die Domain '$DOMAIN' gefunden."
    exit 0
fi

# Ausgabe der Records
echo "$RECORDS" | awk '{printf "%-40s %s\n", $1, $5}'

echo "----------------------------------------"
exit 0
