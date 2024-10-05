#!/bin/bash

### version 0.0.9
### last-modified: 05.10.2024

###
###
###
printf "Projekt Directory (starting like /...): "
read io_project_dir

printf "Name des LEEREN Repository auf github: "
read io_repo


if [ -d "$io_project_dir" ]; then
    
    echo "Dir $io_project_dir exists"
    
    cd $io_project_dir
    
    git init
    
    if [ ! -f "$io_project_dir" ]; then
        git add .
        git commit -m "initial commit"
        git branch -M master
        git remote add origin https://github.com/b1tw0rker/$io_repo.git
        
        
        exit
        git push -u origin master
    fi
    
    
    
    
    
fi

exit 0

