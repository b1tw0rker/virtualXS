#!/bin/bash

file004=/etc/firewall

printf "\n\n***********************************************\n\nCreate /etc/firewall [y/n]: "
if [ "$u_firewall" = "" ]; then
    read u_firewall
fi

if [ "$u_firewall" = "y" ]; then

    if [ ! -d "$file004" ]; then
        mkdir $file004
    fi

    if [ -d "$file004" ]; then
        cp $u_path/files/firewall/stop.sh $file004
        cp $u_path/files/firewall/rules.fw $file004
        cp $u_path/files/firewall/test.sh $file004

        chmod 700 $file004/stop.sh
        chmod 700 $file004/rules.fw
        chmod 700 $file004/test.sh

        sed -i 's/$IPTABLES -A INPUT -i venet0:0   -s 195.90.209.193   -j Cid4533X20228.0/$IPTABLES -A INPUT -i venet0:0   -s '"$u_ip"'   -j Cid4533X20228.0 #by BitWorker/' $file004/rules.fw
        sed -i 's/$IPTABLES -A Cid4533X20228.0  -d 195.90.209.193   -j In_RULE_0/$IPTABLES -A Cid4533X20228.0  -d '"$u_ip"'   -j In_RULE_0 #by BitWorker/' $file004/rules.fw
        sed -i 's/^        load_modules " "/        #load_modules " "/' $file004/rules.fw

        ### muss nach der rule kommen, die noch nach venet0:0 sucht! (see 3 lines above)
        ###
        ###
        sed -i 's/venet0:0/'"$u_eth"'/g' $file004/rules.fw

        ### place client ip in firewall script
        ### $u_client_ip is defined install.sh on top
        ###
        iptables001="    \$IPTABLES -A INPUT  -p tcp -m tcp  -s $u_client_ip\/255.255.255.255  --dport 22  -m state --state NEW,ESTABLISHED -j  ACCEPT"
        iptables002="    \$IPTABLES -A OUTPUT  -p tcp -m tcp  -d $u_client_ip\/255.255.255.255  --sport 22  -m state --state ESTABLISHED,RELATED -j ACCEPT"

        sed -i 's/# backup ssh access/# backup ssh access\n'"$iptables001"'\n'"$iptables002"'/' $file004/rules.fw

        ### DNS Server Special Settings
        ###
        ###
        if [ "$u_server" = "d" ]; then
            sed -i 's/$IPTABLES -A INPUT -p tcp -m tcp  --dport 10000:11000  -m state --state NEW  -j ACCEPT/$IPTABLES -A INPUT -p udp -m udp  --dport 53  -m state --state NEW  -j ACCEPT #by BitWorker/' $file004/rules.fw
            sed -i 's/$IPTABLES -A INPUT -p tcp -m tcp  -m multiport  --dports 88,21,25,80,443,993,995,587  -m state --state NEW  -j ACCEPT/$IPTABLES -A INPUT -p tcp -m tcp  --dport 53  -m state --state NEW  -j ACCEPT #by BitWorker/' $file004/rules.fw
        fi

    fi

    if [ ! -f "/usr/lib/systemd/system/firewall.service" ]; then
        cp $u_path/files/firewall/firewall.service /usr/lib/systemd/system/
    fi

    ### create cronjob in cron.hourly
    ###
    ###
    if [ ! -f "/etc/cron.hourly/firewall-test" ]; then
        cp $u_path/files/firewall/firewall-test /etc/cron.hourly/
        chmod 700 /etc/cron.hourly/firewall-test
    fi

fi

###
###
###

printf "\n\n***********************************************\n\nActivate firewall now [y/n]: "
if [ "$u_activate_firewall" = "" ]; then
    read u_activate_firewall
fi

if [ "$u_activate_firewall" = "y" ]; then

    if [ -f "/usr/lib/systemd/system/firewall.service" ]; then
        systemctl start firewall
    fi

    if [ -f "/etc/firewall/stop.sh" ]; then

        /etc/firewall/stop.sh

        echo "Stopping Firewall"
        iptables -F
        iptables -X
        iptables -t filter -F
        iptables -t filter -X
        iptables -t nat -F
        iptables -t nat -X
        iptables -t mangle -F
        iptables -t mangle -X
        iptables -P INPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT

        iptables -L -n

    fi

    if [ -f "/etc/firewall/rules.fw" ]; then
        systemctl stop fail2ban
        /etc/firewall/rules.fw
        systemctl start fail2ban
    fi

fi

printf "\nTODO: Don't forget to enable Firewall with: -systemctl enable firewall- after reboot\n"
