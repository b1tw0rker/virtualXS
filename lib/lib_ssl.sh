#!/bin/bash



### /etc/ssl/
###
###
if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nCreate new SSL Keypair [y/n]: "
    if [ "$u_ssl" = "" ]; then
        read u_ssl
    fi

else 
    u_ssl=y
fi




if [ "$u_ssl" = "y" ]; then

    ### https://www.thegeekstuff.com/2008/11/3-steps-to-perform-ssh-login-without-password-using-ssh-keygen-ssh-copy-id/
    ### https://stackoverflow.com/questions/43235179/how-to-execute-ssh-keygen-without-prompt/45031320
    ssh-keygen -q -t rsa -b 4096 -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null

    echo "Es wurde ein Neues Keypaar in /root/.ssh/ erstellt."


    printf "Wohin soll der neue Pub Key via ssh-copy-id kopiert werden (Host Adresse, leer für NICHT kopieren)? "
    if [ "$u_new_key" = "" ]; then
        read u_new_key
    fi


    if [ "$u_new_key" != "" ]; then
        /etc/firewall/reset.sh
        ssh-copy-id -i ~/.ssh/id_rsa.pub $u_new_key
        systemctl start firewall
    fi

fi




