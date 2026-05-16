#!/usr/bin/bash

### q install wordpress cli
###
###
if [ "$u_server" = "w" ]; then # Only for web servers
    # Smart default: Y if wp-cli not yet installed, N if already present
    _wp_default="y"
    _wp_prompt="[Y/n]"
    if [ -f "/usr/local/bin/wp" ]; then
        _wp_default="n"
        _wp_prompt="[y/N]"
    fi
    printf "\n********************************************************************\n\nInstall Wordpress CLI (wp-cli)? %s: " "$_wp_prompt"
    if [ -z "$u_wp_cli" ]; then
        read u_wp_cli
        [ "$u_wp_cli" = "" ] && u_wp_cli="$_wp_default"
    fi
    
    if [ "$u_wp_cli" = "y" ]; then
        printf "[\e[36mINFO\e[0m] Installing WP-CLI...\n"
        if curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
            && chmod +x wp-cli.phar \
            && mv wp-cli.phar /usr/local/bin/wp; then
            printf "[\e[32mOK\e[0m] WP-CLI installed to /usr/local/bin/wp\n"
        else
            printf "[\e[31mERROR\e[0m] WP-CLI installation failed\n"
        fi
    fi
fi
