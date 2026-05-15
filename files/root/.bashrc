### bitworker
###
###

### VsCode AI shell integration
### 
###
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash)"



### startet chk service script
###
###
if [[ $- == *i* ]]; then
     /opt/chk-service/bw-chk-service.sh dev
fi

### claude
###
###
alias claude='claude --allowedTools "Bash,Edit,Write,Read,WebSearch"'

