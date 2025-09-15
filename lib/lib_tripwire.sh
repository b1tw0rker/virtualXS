#!/bin/bash

### /etc/tripwire/
###
###
printf "\n\n***********************************************\n\nInstall & Configure Tripwire [y/N]: "
if [ "$u_tripwire" = "" ]; then
    read u_tripwire
fi

if [ "$u_tripwire" = "y" ]; then
    
    # Tripwire ist bereits via dnf installiert (siehe lib_dnf.sh)
    echo "Configuring Tripwire..."
    
    # Konfigurationsdateien
    file_tripwire_policy=/etc/tripwire/twpol.txt
    file_tripwire_config=/etc/tripwire/twcfg.txt
    file_virtualxs_policy=$u_path/files/tripwire/virtualxs-policy.txt
    
    # Backup der ursprünglichen Policy-Datei
    if [ -f "$file_tripwire_policy" ]; then
        cp $file_tripwire_policy ${file_tripwire_policy}.backup
    fi
    
    # VirtualXS-spezifische Überwachungsregeln hinzufügen
    if [ -f "$file_tripwire_policy" ] && [ -f "$file_virtualxs_policy" ]; then
        # Prüfen ob VirtualXS-Regeln bereits hinzugefügt wurden
        if ! grep -q "VirtualXS Tripwire Policy Extensions" "$file_tripwire_policy"; then
            echo "" >> $file_tripwire_policy
            echo "# VirtualXS Tripwire Policy Extensions" >> $file_tripwire_policy
            cat $file_virtualxs_policy >> $file_tripwire_policy
        fi
    fi
    
    # Erstelle /home/httpd/ falls es nicht existiert (für die Überwachung)
    if [ ! -d "/home/httpd" ]; then
        mkdir -p /home/httpd
        chown apache:apache /home/httpd
        chmod 755 /home/httpd
    fi
    
    # Tripwire initialisieren
    echo "Initializing Tripwire..."
    echo "Note: You will be prompted to create passphrases for site and local keys."
    echo "Please remember these passphrases as they will be needed for future operations."
    
    # Konfigurationsdatei erstellen
    if [ ! -f "/etc/tripwire/tw.cfg" ]; then
        tripwire-setup-keyfiles
    fi
    
    # Policy-Datei kompilieren und Datenbank initialisieren
    if [ -f "$file_tripwire_policy" ]; then
        echo "Compiling policy and initializing database..."
        tripwire --init
    fi
    
    # Systemd service aktivieren (falls vorhanden)
    if systemctl list-unit-files | grep -q tripwire; then
        systemctl enable tripwire
        systemctl start tripwire
    fi
    
    echo "Tripwire configuration completed."
    echo "Monitored directories include:"
    echo "  - Standard system directories (/etc, /bin, /sbin, etc.)"
    echo "  - /home/httpd/ (web content)"
    echo "  - /var/log/ (log files)"
    echo ""
    echo "Usage:"
    echo "  - Integrity check: tripwire --check"
    echo "  - Update database: tripwire --update"
    echo "  - Generate report: tripwire --check --interactive"
    
fi