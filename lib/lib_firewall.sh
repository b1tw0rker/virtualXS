#!/bin/bash

file004=/etc/firewall

printf "\n********************************************************************\n\n%d) Create /etc/firewall [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_firewall" = "" ]; then
    read u_firewall
fi

if [ "$u_firewall" = "y" ]; then
    printf "\n"
    if [ ! -d "$file004" ]; then
        mkdir $file004
    fi
    
    if [ -d "$file004" ]; then
        cp $u_path/files/firewall/stop.sh $file004
        cp $u_path/files/firewall/rules.fw $file004
        
        chmod 700 $file004/stop.sh
        chmod 700 $file004/rules.fw
        
        sed -i 's|-s 195.90.209.193/32 -j SPOOF_DENY|-s '"$u_ip"'/32 -j SPOOF_DENY #by BitWorker|' $file004/rules.fw
        
        ### Default interface in rules.fw is enp0s3. Rewrite only for systems using another interface.
        ###
        ###
        if [ -n "$u_iface" ] && [ "$u_iface" != "enp0s3" ]; then
            sed -i 's/enp0s3/'"$u_iface"'/g' $file004/rules.fw
        fi
        
        ### place client ip in firewall script
        ### $u_client_ip is defined install.sh on top
        ###
        iptables001="-A INPUT -p tcp -m tcp -s $u_client_ip\/32 --dport 22 -m conntrack --ctstate NEW -j ACCEPT #by BitWorker"
        
        sed -i 's/# Emergency SSH access. Installer may add another fixed source here.$/# Emergency SSH access. Installer may add another fixed source here.\n'"$iptables001"'/' $file004/rules.fw
        
        ### DNS Server Special Settings
        ###
        ###
        if [ "$u_server" = "d" ]; then
            dns001="-A INPUT -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT #by BitWorker"
            dns002="-A INPUT -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT #by BitWorker"
            sed -i 's/# Public input services.$/# Public input services.\n'"$dns001"'\n'"$dns002"'/' $file004/rules.fw
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

    _log ok "/etc/firewall configured"
    
fi

###
###
###

printf "\n********************************************************************\n\n%d) Activate firewall now [y/N]: " "$(( ++_vxs_step ))"
if [ "$u_activate_firewall" = "" ]; then
    read u_activate_firewall
fi

if [ "$u_activate_firewall" = "y" ]; then
    printf "\n"
    if [ -f "/usr/lib/systemd/system/firewall.service" ]; then
        systemctl start firewall
    fi
    
    if [ -f "/etc/firewall/stop.sh" ]; then
        
        /etc/firewall/stop.sh
        
        _log info "Stopping Firewall"
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

    _log ok "Firewall activated"
    
fi

_log info "Don't forget to enable Firewall with: systemctl enable firewall -- after reboot"

printf "\n********************************************************************\n\n"

### https://www.cyberciti.biz/faq/linux-kernel-etcsysctl-conf-security-hardening/
###
###
if confirm "$(( ++_vxs_step ))) Kernel-Hardening (ASLR, SYN-Flood, Redirect-/Spoofing-Schutz, Kernel-Pointer, Symlink-Schutz)" "$u_hardening"; then
    
    folder001=/etc/sysctl.d
    
    if [ ! -d "$folder001" ]; then
        mkdir $folder001
    fi
    
    if ! cp $u_path/files/firewall/99-bw-kernel-hardening.conf $folder001; then
        _log error "cp 99-bw-kernel-hardening.conf failed"
    else
        ### activate kernel rules
        ###
        ###
        sysctl -p "$folder001/99-bw-kernel-hardening.conf"
        _log ok "Kernel hardening applied"
    fi
    
fi

### we want to be absolutly sure that firewalld is turned off
###
###
if [ -f "/etc/systemd/system/multi-user.target.wants/firewalld.service" ]; then
    systemctl disable firewalld
fi
