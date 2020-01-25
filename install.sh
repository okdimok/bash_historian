#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function __bak_file () {
    [ -f $1 ] && cp $1 "${1}.bash_historian.bak" 
}
__bak_file ${HOME}/.bashrc
__bak_file ${HOME}/.bash_aliases
__bak_file ${HOME}/.bash_history
# Currently, only default history location is backed up. No way to learn, where the history is stored in an interactive session. Even starting an interactive session inside and sourcing bashrc doesn't help
# this outputs a HISTFILE to a file
# doesn't work yet
#bash --init-file <(echo ". ${HOME}/.bashrc; set | grep HISTFILE | grep -v SIZE | cut -d = -f 2  > /tmp/histfile")
#HF=`cat /tmp/histfile`


sed -i '/\(HIST\|PROMPT_COMMAND\|hist\|ignoreboth\|ignoredups\|ignorespace\)/ s/^/#/' ${HOME}/.bashrc
sed -i '/\(HIST\|PROMPT_COMMAND\|hist\|ignoreboth\|ignoredups\|ignorespace\)/ s/$/ ### commented out by Bash Historian/' ${HOME}/.bashrc

echo "" > ${DIR}/.bash_aliases_local_before
cat ${DIR}/.bash_aliases_local_template >> ${DIR}/.bash_aliases_local_before