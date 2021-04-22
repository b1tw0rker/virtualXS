#!/bin/bash




### /etc/ssh/sshd_config
###
###
if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nConfigure  /etc/ssh/sshd_config [y/n]: "
    if [ "$u_ssh" = "" ]; then
        read u_ssh
    fi


else 
    u_ssh=y
fi





if [ "$u_ssh" = "y" ]; then

    file_ssh001=/etc/ssh/sshd_config

    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' $file_ssh001
    sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' $file_ssh001
    sed -i 's/^#MaxAuthTries 6/MaxAuthTries 2/' $file_ssh001
    sed -i 's/^#UseDNS no/UseDNS no/' $file_ssh001

    #grep BitWorker
    u_bitworker=$(grep -m 1 "### by BitWorker" /etc/ssh/sshd_config)


    if [ -f "$file_ssh001" ] && [ "$u_bitworker" != "### by BitWorker" ]; then
            cat $u_path/files/ssh/sshd_config >> $file_ssh001
    fi

    cp $u_path/files/ssh/authorized_keys /root/.ssh/
    

    systemctl restart sshd

fi






