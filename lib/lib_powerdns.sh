#!/bin/bash

### Docs
### https://doc.powerdns.com/md/httpapi/README/
### https://www.howtoforge.de/anleitung/wie-installiert-man-powerdns-server-und-powerdns-admin-unter-ubuntu-20-04/
### PowerDNS-Admin
### https://github.com/ngoduykhanh/PowerDNS-Admin/wiki/Running-PowerDNS-Admin-on-Centos-7
###
### Master und Slave Config
### https://www.claudiokuenzler.com/blog/844/powerdns-master-slave-dns-replication-mysql-backend

### globale DNS vars
###
###
dns_apps="net-tools which bind-utils whois rsyslog iptraf-ng dnf-automatic rsync tar wget ncftp unzip git pdns pdns-backend-mysql pdns-recursor pdns-tools mysql mysql-server jq"
file_powerdns001=/etc/pdns/pdns.conf
file_powerdns_repo=/etc/yum.repos.d/powerdns-rec-54.repo

### Recursor 5.x: recursor.yml aus Vorlage anlegen (nur wenn noch keine existiert)
### recursor.yml-dist liefert nur 5.x mit; 4.x liest recursor.conf und bleibt unberuehrt.
###
_powerdns_recursor_yml() {
    local file_yml=/etc/pdns-recursor/recursor.yml
    if [ -f "$file_yml" ]; then
        _log ok "recursor.yml exists (skipping)"
    elif [ -f /etc/pdns-recursor/recursor.yml-dist ]; then
        cp "$u_path/files/powerdns/recursor.yml" "$file_yml"
        chmod 644 "$file_yml"
        _log ok "recursor.yml created"
    fi
}

### q PowerDNS-Repo zufuegen
### Die Recursor-Pakete aus EPEL sind veraltet (4.8.x kennt den Root-KSK-2026 nicht,
### SERVFAIL ab 11.10.2026). Das PowerDNS-Repo liefert den aktuellen 5.4-Zweig.
### Hinweis: 5.x liest nur noch /etc/pdns-recursor/recursor.yml (kein recursor.conf).
###
(( _vxs_step++ ))
if [ -f "$file_powerdns_repo" ]; then
    printf "\n********************************************************************\n\n%d) PowerDNS-Repo zufügen für PowerDNS Update (empfohlen) [Y/n]:\n" "$_vxs_step"
    _log ok "(already active - skipping)"
    u_powerdns_repo=n
else
    printf "\n********************************************************************\n\n%d) PowerDNS-Repo zufügen für PowerDNS Update (empfohlen) [Y/n]: " "$_vxs_step"
    if [ "$u_powerdns_repo" = "" ]; then
        read u_powerdns_repo
        [ "$u_powerdns_repo" = "" ] && u_powerdns_repo="y"
    fi
fi

if [ "$u_powerdns_repo" = "y" ]; then
    printf "\n"
    cp "$u_path/files/powerdns/powerdns-rec-54.repo" "$file_powerdns_repo"
    chmod 644 "$file_powerdns_repo"
    _log ok "PowerDNS repo added"
fi

### q Install Master PowerDNS
###
###
printf "\n********************************************************************\n\n%d) Install Master PowerDNS [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_powerdns_master" = "" ]; then
    read u_powerdns_master
fi

if [ "$u_powerdns_master" = "y" ]; then
    printf "\n"
    u_powerdns_slave=n

    dnf -y install $dns_apps
    _powerdns_recursor_yml

    ### start mysql
    ###
    ###
    systemctl start mysqld

    ### set root pass
    ###
    ###
    mysql_pwd=$(grep '^password=' /root/.my.cnf | cut -d'=' -f2-)
    if mysqladmin -u root password "$mysql_pwd" >>/dev/null 2>&1; then
        _log ok "Changed MySql root pass success"
    fi

    ### install powerdns mysql scheme
    ###
    ###
    mysql -u root <$u_path/files/powerdns/schema-4.7.mysql.sql

    sed -i 's/^# local-address=0.0.0.0, ::/local-address='"$u_ip4"', ::/' $file_powerdns001
    sed -i 's/^# master=no/master=yes/' $file_powerdns001
    sed -i 's/^launch=bind/# launch=bind/' $file_powerdns001

    ###grep BitWorker
    u_bitworker=$(grep -m 1 "### by BitWorker" /etc/pdns/pdns.conf)

    if [ -f "$file_powerdns001" ] && [ "$u_bitworker" != "### by BitWorker" ]; then
        cat $u_path/files/powerdns/gmysql.cf >>$file_powerdns001
        sed -i 's/^gmysql-user=pdnsadmin/gmysql-user=root/' $file_powerdns001
        sed -i 's/^gmysql-password=password/gmysql-password='"$mysql_pwd"'/' $file_powerdns001
    fi
    unset mysql_pwd

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/mysqld.service" ]; then
        systemctl enable mysqld
    fi

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/pdns.service" ]; then
        systemctl enable pdns
    fi

    systemctl start mysqld
    systemctl start pdns

fi

### q Install Slave PowerDNS
###
###
printf "\n********************************************************************\n\n%d) Install Slave PowerDNS [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_powerdns_slave" = "" ]; then
    read u_powerdns_slave
fi

if [ "$u_powerdns_slave" = "y" ]; then
    printf "\n"
    read -p "Master Server IP: " u_master_server_ip
    # Reverse Lookup mit dig
    u_reverse=$(dig +short -x $u_master_server_ip | sed 's/\.$//')

    read -p "Slave Server FQDN (example: ns1.$u_domain): " -ei $u_reverse u_slave_server_fqdn

    dnf -y install $dns_apps
    _powerdns_recursor_yml

    ### start mysql
    ###
    ###
    systemctl start mysqld

    mysql -u root <$u_path/files/powerdns/schema-4.7.mysql.sql

    sed -i 's/^# local-address=0.0.0.0, ::/local-address='"$u_ip4"', ::/' $file_powerdns001
    sed -i 's/^# slave=no/slave=yes/' $file_powerdns001
    sed -i 's/^# slave-cycle-interval=60/slave-cycle-interval=60/' $file_powerdns001
    sed -i 's/^# autosecondary=no/autosecondary=yes/' $file_powerdns001
    sed -i 's/^launch=bind/# launch=bind/' $file_powerdns001

    ### grep BitWorker
    ###
    ###
    u_bitworker=$(grep -m 1 "### by BitWorker" /etc/pdns/pdns.conf)

    if [ -f "$file_powerdns001" ] && [ "$u_bitworker" != "### by BitWorker" ]; then
        mysql_pwd=$(grep '^password=' /root/.my.cnf | cut -d'=' -f2-)
        cat $u_path/files/powerdns/gmysql.cf >>$file_powerdns001
        sed -i 's/^gmysql-user=pdnsadmin/gmysql-user=root/' $file_powerdns001
        sed -i 's/^gmysql-password=password/gmysql-password='"$mysql_pwd"'/' $file_powerdns001
        unset mysql_pwd
    fi

    if [ "$u_master_server_ip" != "" ] && [ "$u_slave_server_fqdn" != "" ]; then
        mysql -u root -e "INSERT INTO powerdns.supermasters (ip, nameserver, account) VALUES ('$u_master_server_ip', '$u_slave_server_fqdn', 'admin');"
    fi

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/mysqld.service" ]; then
        systemctl enable mysqld
    fi

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/pdns.service" ]; then
        systemctl enable pdns
    fi

    systemctl start pdns

    printf "**********************************************************************************************************\n"
    printf "*** Don't forget to insert udp/tcp port 53 network traffic from master to slave in your iptables script ***\n"
    printf "**********************************************************************************************************\n"
    _log ok "PowerDNS configured"

fi
