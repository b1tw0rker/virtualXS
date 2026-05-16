#!/bin/bash

### /etc/tripwire/
###
###
printf "\n********************************************************************\n\nInstall & Configure Tripwire [y/N]: "
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
    
    # Backup of the original policy file
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
    
    # Enable systemd service (if available)
    if systemctl list-unit-files | grep -q tripwire; then
        systemctl enable tripwire
        systemctl start tripwire
    fi
    
    printf "[\e[32mOK\e[0m] Tripwire configured\n"
    printf "[\e[36mINFO\e[0m] Monitored directories include:\n"
    printf "[\e[36mINFO\e[0m]   - Standard system directories (/etc, /bin, /sbin, etc.)\n"
    printf "[\e[36mINFO\e[0m]   - /home/httpd/ (web content)\n"
    printf "[\e[36mINFO\e[0m]   - /var/log/ (log files)\n"
    printf "[\e[36mINFO\e[0m] Usage:\n"
    printf "[\e[36mINFO\e[0m]   - Integrity check: tripwire --check\n"
    printf "[\e[36mINFO\e[0m]   - Update database: tripwire --update\n"
    printf "[\e[36mINFO\e[0m]   - Generate report: tripwire --check --interactive\n"
    
fi