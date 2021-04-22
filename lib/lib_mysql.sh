#!/bin/bash



### /MySQL/
###
###
if [ "$u_all" != "y" ]; then
    printf "\n***********************************************\n\nConfigure MySQL Stuff [y/n]: "
    if [ "$u_mysql" = "" ]; then
        read u_mysql
    fi

else 
    u_mysql=y
fi




if [ "$u_mysql" = "y" ]; then

    file_mysql001=/etc/bitworker

    if [ ! -d "$file_mysql001" ]; then
      mkdir $file_mysql001
    fi


    cp $u_path/files/mysql/mysqldump.sh $file_mysql001
    chmod 700 $file_mysql001/mysqldump.sh

    #Set root Pass
    # https://www.dogado.de/faq/artikel/mysql-root-passwort-neu-setzen/
    read -p "Set first MySQL root Password: " -ei $u_root_pwd u_mysql_pwd

    mysqladmin -u root password $u_mysql_pwd >> /dev/null 2>&1

    sed -i 's/^MYSQL_PASSWORD=XXX/MYSQL_PASSWORD='"$u_mysql_pwd"'/' $file_mysql001/mysqldump.sh



    
fi




