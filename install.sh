#!/usr/bin/env bash
function __bak_file () {
    [ -f $1 ] && cp $1 "${1}.bash_historian.bak" 
}
__bak_file ${HOME}/.bash_history
__bak_file ${HOME}/.bashrc
__bak_file ${HOME}/.bash_aliases

sed -i '/\(HIST\|PROMPT_COMMAND\|hist\|ignoreboth\|ignoredups\|ignorespace\)/ s/^/#/' ${HOME}/.bashrc

## this doesn't work: have to set up HISTFILE, but it makes no sense
#set -o history
#history | sed 's/^[ ]*[0-9]\+[ ]*//' >> ${HOME}/history.bash_historian.bak
#set +o history
