#!/bin/bash

### Append root .bashrc additions
###
###
printf "\n********************************************************************\n\n"
if confirm "$(( ++_vxs_step ))) Append root .bashrc additions (claude alias, chk-service)" "$u_bashrc_root"; then

    if grep -qF 'bw-chk-service' /root/.bashrc 2>/dev/null; then
        _log info "/root/.bashrc additions already present – skipping"
    else
        cat "$u_path/files/root/.bashrc" >> /root/.bashrc
        _log ok "/root/.bashrc updated"
        # shellcheck source=/dev/null
        source /root/.bashrc
        _log info "/root/.bashrc sourced – changes active in current session"
    fi

fi

