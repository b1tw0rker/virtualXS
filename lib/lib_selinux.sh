#!/bin/bash

if [ -f "/etc/selinux/config" ]; then

    sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

fi
