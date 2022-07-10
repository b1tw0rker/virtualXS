#!/bin/bash

for path in /home/httpd/*/tmp; do

    ### action
    ###
    ###
    find $path -cmin +480 -type f -name "sess_*" -exec rm {} \;

done

exit 0
