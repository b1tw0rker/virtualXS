#!/usr/bin/bash

### q install wordpress cli
###
###
if [ "$u_server" = "w" ]; then # Only for web servers
    printf "\n\n***********************************************\n\nInstall Wordpress CLI (wp-cli)? [y/N]: "
    if [ -z "$u_wp_cli" ]; then
        read u_wp_cli
    fi
    
    if [ "$u_wp_cli" = "y" ]; then
        echo "Installing WP-CLI..."
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
        echo "WP-CLI installed to /usr/local/bin/wp"
    fi
fi
