#!/bin/bash

### version 1.0.0
### last-modified: 05.10.2024

### requirements: curl, git, github cli, ssh-keygen
### gh-cli
### sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
### sudo dnf install gh


### vars
###
###
token=""
usr="b1tw0rker"
mail="mail@bit-worker.com"
branch="main"

###
###
###
printf "Name des neuen Repository auf github: "
read io_repo

read -p "Projekt Directory (fullpath, no ending slash): " -e -i "/opt/$io_repo" io_project_dir



###
###
###
if [ ! -d "$io_project_dir" ]; then
    mkdir -p $io_project_dir
    echo "Inital Commit" > $io_project_dir/README.md
    echo "**/sshd_config\n**/authorized_keys\n**/sources" > $io_project_dir/.gitignore
    new=true
fi


###
###
###
if [ "$new" == "true" ]; then
    echo "Dir: $io_project_dir created."
else
    echo "Dir: $io_project_dir exists."
fi



###
###
###
if [ -d "$io_project_dir" ]; then
    
    
    cd $io_project_dir
    
    git init
    
    
    ### create remote repo with github API
    ###
    ###
    printf "Neues Repository auf github erstellen (y/N): "
    read io_github_repo
    
    if [ "$io_github_repo" == "y" ]; then
        
        
        printf "Dies Repo ist privat (y/N): "
        read io_github_private
        
        if [ "$io_github_private" == "y" ]; then
            privacy="true"
        else
            privacy="false"
        fi
        
        curl -H "Authorization: token $token" -d "{\"name\": \"$io_repo\", \"private\": $privacy}" https://api.github.com/user/repos
        # xperimental stuff
        #gh auth login
        #gh repo create "$io_repo" --private=$privacy
        
    fi
    
    ### init lokale repository
    ###
    ###
    git add .
    git commit -m "initial commit"
    git branch -M $branch
    git remote add origin git@github.com:$usr/$io_repo.git
    
    
    
    
    ### bearbeite git config
    ###
    ###
    if [ -f "$io_project_dir/.git/config" ]; then
        git config user.name "$usr"
        git config user.email "$mail"
    fi
    
    
    
    
    
    
    ### push to github
    ###
    ###
    git push -u origin $branch
    
    
fi

exit 0

