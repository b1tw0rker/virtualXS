#!/bin/bash

### set crypto-polcies to legacy
### https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/using-the-system-wide-cryptographic-policies_security-hardening
###
printf "\n\n***********************************************\n\nSet Rocky 9 crypto-policies to LEGACY [y/N]: "
if [ "$u_crypto" = "" ]; then
    read u_crypto
fi

if [ "$u_crypto" = "y" ]; then
    update-crypto-policies --set LEGACY
fi
