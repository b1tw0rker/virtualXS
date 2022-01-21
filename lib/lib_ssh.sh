#!/bin/bash




### /etc/ssh/sshd_config
###
###
printf "\n\n***********************************************\n\nConfigure  /etc/ssh/sshd_config [y/n]: "
if [ "$u_ssh" = "" ]; then
        read u_ssh
fi





if [ "$u_ssh" = "y" ]; then

    file_ssh001=/etc/ssh/sshd_config
    file_ssh002=/etc/ssh/sshd_config.bak

    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' $file_ssh001
    sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' $file_ssh001
    sed -i 's/^#MaxAuthTries 6/MaxAuthTries 2/' $file_ssh001
    sed -i 's/^#UseDNS no/UseDNS no/' $file_ssh001

    #grep BitWorker
    u_bitworker=$(grep -m 1 "### by BitWorker" /etc/ssh/sshd_config)


    if [ -f "$file_ssh001" ] && [ "$u_bitworker" != "### by BitWorker" ]; then
            # make backup
            cp $file_ssh001 $file_ssh002
            cat $u_path/files/ssh/sshd_config >> $file_ssh001
            # add backup remote client ssh connection
            sed -i 's/^Match Host XXX/Match Host '"$u_client_ip"'/' $file_ssh001
    fi

    cp $u_path/files/ssh/authorized_keys /root/.ssh/
    

    systemctl restart sshd

fi






