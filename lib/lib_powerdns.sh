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

### q Install Master PowerDNS
###
###
printf "\n\n***********************************************\n\nInstall Master PowerDNS [y/n]: "
if [ "$u_powerdns_master" = "" ]; then
    read u_powerdns_master
fi

if [ "$u_powerdns_master" = "y" ]; then

    u_powerdns_slave=n

    dnf -y install $dns_apps

    ### start mysql
    ###
    ###
    systemctl start mysqld

    ### set root pass
    ###
    ###
    mysqladmin -u root password $u_mysql_pwd >>/dev/null 2>&1

    ### install powerdns mysql scheme
    ###
    ###
    MYSQL_PWD=$u_mysql_pwd mysql -u root <$u_path/files/powerdns/schema.mysql.sql

    sed -i 's/^# local-address=0.0.0.0, ::/local-address='"$u_ip4"', ::/' $file_powerdns001
    sed -i 's/^# master=no/master=yes/' $file_powerdns001
    sed -i 's/^launch=bind/# launch=bind/' $file_powerdns001

    ###grep BitWorker
    u_bitworker=$(grep -m 1 "### by BitWorker" /etc/pdns/pdns.conf)

    if [ -f "$file_powerdns001" ] && [ "$u_bitworker" != "### by BitWorker" ]; then
        cat $u_path/files/powerdns/gmysql.cf >>$file_powerdns001
        sed -i 's/^gmysql-user=pdnsadmin/gmysql-user=root/' $file_powerdns001
        sed -i 's/^gmysql-password=password/gmysql-password='"$u_mysql_pwd"'/' $file_powerdns001
    fi

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
printf "\n\n***********************************************\n\nInstall Slave PowerDNS [y/n]: "
if [ "$u_powerdns_slave" = "" ]; then
    read u_powerdns_slave
fi

if [ "$u_powerdns_slave" = "y" ]; then

    read -p "Master Server IP: " u_master_server_ip
    read -p "Slave Server FQDN (example: ns1.domain.org): " -ei $u_srv u_slave_server_fqdn

    dnf -y install $dns_apps

    ### start mysql
    ###
    ###
    systemctl start mysqld

    MYSQL_PWD=$u_mysql_pwd mysql -u root <$u_path/files/powerdns/schema.mysql.sql

    sed -i 's/^# local-address=0.0.0.0, ::/local-address='"$u_ip4"', ::/' $file_powerdns001
    sed -i 's/^# slave=no/slave=yes/' $file_powerdns001
    sed -i 's/^# slave-cycle-interval=60/slave-cycle-interval=60/' $file_powerdns001
    sed -i 's/^# autosecondary=no/autosecondary=yes/' $file_powerdns001
    sed -i 's/^launch=bind/# launch=bind/' $file_powerdns001

    ###grep BitWorker
    u_bitworker=$(grep -m 1 "### by BitWorker" /etc/pdns/pdns.conf)

    if [ -f "$file_powerdns001" ] && [ "$u_bitworker" != "### by BitWorker" ]; then
        cat $u_path/files/powerdns/gmysql.cf >>$file_powerdns001
        sed -i 's/^gmysql-user=pdnsadmin/gmysql-user=root/' $file_powerdns001
        sed -i 's/^gmysql-password=password/gmysql-password='"$u_mysql_pwd"'/' $file_powerdns001
    fi

    if [ "$u_master_server_ip" != "" ] && [ "$u_slave_server_fqdn" != "" ]; then
        MYSQL_PWD=$u_mysql_pwd mysql -u root -e "INSERT INTO powerdns.supermasters (ip, nameserver, account) VALUES ('$u_master_server_ip', '$u_slave_server_fqdn', 'admin');"
    fi

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/mysqld.service" ]; then
        systemctl enable mysqld
    fi

    if [ ! -f "/etc/systemd/system/multi-user.target.wants/pdns.service" ]; then
        systemctl enable pdns
    fi

    systemctl start pdns

    printf "*******************************************************************************************************\n"
    printf "*** Don't forget to insert udp port 53 network traffic from master to slave in your iptables script ***\n"
    printf "*******************************************************************************************************\n"

fi
