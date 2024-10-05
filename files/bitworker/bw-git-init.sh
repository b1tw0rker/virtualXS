#!/bin/bash

### version 1.0.0
### last-modified: 05.10.2024

###
###
###
printf "Name des vollständigen (keine README.md) LEEREN Repository auf github: "
read io_repo


printf "Projekt Directory (starting like /...): "
read io_project_dir


if [ -d "$io_project_dir" ]; then
    
    echo "Dir $io_project_dir exists"
    
    cd $io_project_dir
    
    git init
    
    if [ ! -f "$io_project_dir" ]; then
        git add .
        git commit -m "initial commit"
        git branch -M master
        git remote add origin https://github.com/b1tw0rker/$io_repo.git
        
        exit 0
        
        
        sed -i 's|url = https://github.com/b1tw0rker/virtualx-build.git|url = https://github.com/b1tw0rker/www.host-x.de.git|' /root/virtualsx-bild/.git/config
        
        git config user.name "b1tw0rker"
        git config user.email "mail@bit-worker.com"
        
        
        git push -u origin master
    fi
    
    
    
    
    
fi

exit 0

