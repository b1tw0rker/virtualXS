#!/bin/bash

# Funktion für das Protokollieren
# version 1.0.2
# last-modified. 13.12.2023
function bwLogger() {
    local msg="$1"

    if [ "$STDIN" = "prod" ]; then
        # nur loggen wenn Trigger Achtung gesetzt ist.
        if [[ "$msg" =~ ^\[[Aa][Cc][Hh][Tt][Uu][Nn][Gg]\] ]]; then
            logger -t checksec -p warn "Checksec: $HOSTNAME: $msg"
        fi
    fi

    # Konsoleausgabe, wenn $STDIN "dev" ist
    if [ "$STDIN" = "dev" ]; then
        # Überprüfen, ob $msg [Achtung] oder [ACHTUNG] am Anfang der Zeichenkette enthält
        if [[ "$msg" =~ ^\[[Aa][Cc][Hh][Tt][Uu][Nn][Gg]\] ]]; then
            # Ersetzen von [Achtung] durch [ACHTUNG] am Anfang der Zeichenkette und in Rot formatieren
            msg="$MSG_ACHTUNG${msg:9}"
        fi
        if [[ "$msg" =~ ^\[[Oo][Kk]\] ]]; then
            # Ersetzen von [Ok] durch [OK] am Anfang der Zeichenkette und in grün formatieren
            msg="$MSG_OK${msg:4}"
        fi
        echo -e "$msg"
    fi
}

# Headline
# version 1.0.0
# last-modified. 14.12.2023
function bwHeadline() {
    if [ "$STDIN" = "dev" ]; then
        local lineWidth=71 # Breite ohne die beiden Randsterne
        local textLength=${#1}
        local totalPadding=$((lineWidth - textLength))
        local paddingLeft=$((totalPadding / 2))
        local paddingRight=$((totalPadding - paddingLeft))

        echo ""
        echo "*************************************************************************"
        printf "*%*s%*s*\n" $((paddingLeft + textLength)) "$1" $paddingRight ""
        echo "*************************************************************************"
        echo ""
    fi
}

# Funktion, um Dienste aus der Konfigurationsdatei chk-service.cfg zu überprüfen
# version 1.0.0
# last-modified. 23.12.2023
function chk_services() {

    bwHeadline "CHECK STARTSCRIPTE"

    CONFIG_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bw-chk-service.cfg"

    if [ ! -f "$CONFIG_FILE" ]; then
        bwLogger "$MSG_ACHTUNG Konfigurationsdatei $CONFIG_FILE nicht gefunden."
        exit 1
    fi

    sort "$CONFIG_FILE" | while IFS= read -r service; do
        if [[ $service =~ ^#.* ]]; then
            continue
        fi

        # check if service is active
        systemctl is-active --quiet "$service"

        if [ $? -eq 0 ]; then
            bwLogger "$MSG_OK $service läuft."
        else
            bwLogger "$MSG_ACHTUNG $service ist nicht aktiv!"
        fi
    done

}

# Überprüfe lokale Dienste
# version 1.0.0
# last-modified. 14.12.2023
function chk_local_services() {
    SERVICES_DIR="/etc/systemd/system/multi-user.target.wants"

    if [ ! -d "$SERVICES_DIR" ]; then
        echo "Verzeichnis $SERVICES_DIR nicht gefunden."
        exit 1
    fi

    # Durchlaufen aller symbolischen Links im Verzeichnis
    for service_path in "$SERVICES_DIR"/*; do
        # Extrahiere den Namen des Dienstes aus dem Pfad
        service=$(basename "$service_path" .service)

        # Überprüfe den Status des Dienstes
        systemctl is-active --quiet "$service"
        if [ $? -eq 0 ]; then
            bwLogger "$MSG_OK $service läuft."
        else
            bwLogger "$MSG_ACHTUNG $service ist nicht aktiv!"
        fi
    done

}

# Überprüfen, ob der Kernel Panic ausgelöst wurde und ob der Kernel Panic Rescue Modus aktiviert ist
# version 1.0.1
# last-modified. 14.12.2023
function chk_kernel_panic() {
    #bwHeadline "CHECK KERNEL PANIC STATUS"

    # Überprüfen, ob der Kernel Panic einen Neustart auslöst.
    if [ -f /proc/sys/kernel/panic ]; then
        panic=$(cat /proc/sys/kernel/panic)

        if [ "$panic" -gt 0 ]; then
            bwLogger "$MSG_ACHTUNG Kernel wird nach Panic in $panic Sekunden neu gestartet."
        else
            bwLogger "$MSG_OK Kernel wird nach Panic nicht neu gestartet."
        fi
    else
        bwLogger "$MSG_ACHTUNG Kernel Neustart nach Panic ist nicht konfiguriert."
    fi

    # Überprüfen, ob der Kernel Panic Rescue Modus aktiviert ist
    directory="/etc/sysctl.d"
    result=$(grep -r --include "*" "^[^#]*kernel\.panic = 10" "$directory")

    # Überprüfe, ob das Ergebnis der Suche leer ist
    if [ -z "$result" ]; then
        bwLogger "$MSG_ACHTUNG kernel.panic = 10 in $directory nicht gefunden"
    else
        bwLogger "$MSG_OK kernel.panic = 10 gefunden: $result"
    fi
}
