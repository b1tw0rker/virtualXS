!/bin/bash

# version 1.0
# last modified: 05.09.2024

# Erstellt von und mit ChatGPT
# Erstelle Backups von VMs basierend auf einer Konfigurationsdatei

# Log-Datei für Fehlermeldungen festlegen
LOG_FILE="/var/log/vm_backup.log"
CFG_FILE="/etc/bitworker/bw-backup-vm.cfg"

# Fehler-Handler-Funktion
error_handler() {
    echo "Ein Fehler ist aufgetreten. Siehe $LOG_FILE für Details." >> "$LOG_FILE"
    exit 1
}

# Trap-Anweisung, um Fehler abzufangen und den Fehler-Handler aufzurufen
trap 'error_handler' ERR

# Startzeit des gesamten Skripts aufzeichnen
START_TIME=$(date +%s)

# Überprüfen, ob die Konfigurationsdatei existiert
if [ ! -f "$CFG_FILE" ]; then
    echo "Konfigurationsdatei $CFG_FILE nicht gefunden." | tee -a "$LOG_FILE"
    exit 1
fi

# Alle VMs aus der Konfigurationsdatei auslesen
VMS=$(cat "$CFG_FILE")

# Durchlaufen aller VMs, die in der Konfigurationsdatei aufgelistet sind
for VM_NAME in $VMS; do
    # Startzeit für das aktuelle Backup
    VM_START_TIME=$(date +%s)

    # Pfad und Dateiname für das Backup erstellen
    BACKUP_PATH="/home/virtualbox-backup/${VM_NAME}.ova"

    # Überprüfen, ob die Backup-Datei bereits existiert
    if [ -f "$BACKUP_PATH" ]; then
        # Vorhandene Backup-Datei umbenennen
        echo "Backup-Datei $BACKUP_PATH existiert bereits. Erstelle .bak Datei."
        mv -f "$BACKUP_PATH" "${BACKUP_PATH}.bak"
    fi

    # Abrufen des aktuellen Zustands der VM
    VM_STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep '^VMState=' | cut -d '"' -f 2)

    # Speichern des ursprünglichen VM-Zustands
    ORIGINAL_VM_STATE="$VM_STATE"

    # Überprüfen, ob die VM heruntergefahren ist
    if [ "$VM_STATE" = "poweroff" ]; then
        echo "VM $VM_NAME ist bereits heruntergefahren."
    else
        # Herunterfahren der VM
        echo "Fahre VM herunter: $VM_NAME"
        VBoxManage controlvm "$VM_NAME" acpipowerbutton

        # Warte, bis die VM heruntergefahren ist
        while VBoxManage showvminfo --machinereadable "$VM_NAME" | grep -q '^VMState="running"'; do
            sleep 1
        done
    fi

    # Starten des Exports
    echo "Exportiere VM: $VM_NAME"
    VBoxManage export "$VM_NAME" --output "$BACKUP_PATH"

    # VM wieder starten, nur wenn sie ursprünglich lief
    if [ "$ORIGINAL_VM_STATE" = "running" ]; then
        echo "Starte VM: $VM_NAME"
        VBoxManage startvm "$VM_NAME" --type headless
    fi

    # Endzeit für das aktuelle Backup
    VM_END_TIME=$(date +%s)

    # Berechnen der Dauer des aktuellen Backups in Minuten
    VM_ELAPSED_TIME=$((VM_END_TIME - VM_START_TIME))
    VM_ELAPSED_MINUTES=$((VM_ELAPSED_TIME / 60))
    echo "Backup für VM $VM_NAME abgeschlossen: $BACKUP_PATH. Dauer: $VM_ELAPSED_MINUTES Minuten." >> "$LOG_FILE"
done

# Endzeit des gesamten Skripts aufzeichnen
END_TIME=$(date +%s)

# Berechnen der verstrichenen Zeit für das gesamte Skript in Minuten
ELAPSED_TIME=$((END_TIME - START_TIME))
ELAPSED_MINUTES=$((ELAPSED_TIME / 60))

echo "Alle Backups abgeschlossen. Gesamtlaufzeit des Skripts: $ELAPSED_MINUTES Minuten." | tee -a "$LOG_FILE"

exit

