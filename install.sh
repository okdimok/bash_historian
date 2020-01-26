#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function __bak_file () {
	input_file=$1
	output_file="${input_file}.bash_historian.bak" 
	[[ -f $input_file ]] || return 0
	[[ ! -f $output_file ]] && cp ${input_file} ${output_file} && return 0;
	for i in {0..1000}; do
		output_file_i="${output_file}.${i}"
		if [[ ! -f $output_file_i ]]; then
			cp ${input_file} ${output_file_i}
			return 0;
		fi
	done;
	return 1; # all 1000 copies exist
}
__bak_file ${HOME}/.bashrc
__bak_file ${HOME}/.bash_aliases
__bak_file ${HOME}/.bash_history
# Currently, only default history location is backed up. No way to learn, where the history is stored in an interactive session. Even starting an interactive session inside and sourcing bashrc doesn't help
# this outputs a HISTFILE to a file
# doesn't work yet
#bash --init-file <(echo ". ${HOME}/.bashrc; set | grep HISTFILE | grep -v SIZE | cut -d = -f 2  > /tmp/histfile")
#HF=`cat /tmp/histfile`

cp ${DIR}/home_bash_aliases_template ${HOME}/.bash_aliases

if [[ ! -f ${DIR}/install_configuration ]]; then
	cp ${DIR}/install_configuration_template ${DIR}/install_configuration
	echo "Please edit ${DIR}/install_configuration to set the history repository. It has been created from a template."
	exit 0;
fi;

source ${DIR}/install_configuration

[[ -z $BASH_HISTORY_TEMPLATE_EDITED ]] && echo "You have not edited BASH_HISTORY_TEMPLATE_EDITED var. Please edit ${DIR}/install_configuration to set the history repository. It has been created from a template." && exit 1 || echo "Loaded proper config from ${DIR}/install_configuration";

if [[ ! -z $BASH_HISTORY_SSH_KEY ]]; then
	echo $BASH_HISTORY_SSH_KEY > ${DIR}/ssh_key
fi
 
[[ -f ${DIR}/ssh_key ]] && ssh-add ${DIR}/ssh_key

if [[ ! -z $BASH_HISTORY_REPOSITORY ]]; then
    __cmd="git clone";
    [[ ! -z $BASH_HISTORY_BRANCH ]] && __cmd="${__cmd} --branch ${BASH_HISTORY_BRANCH}"
    __cmd="${__cmd} ${BASH_HISTORY_REPOSITORY} ${HOME}/bash_history"
    eval "${__cmd}" && BRANCH_FOUND=1
    if [[ -z $BRANCH_FOUND ]]; then
        git clone ${BASH_HISTORY_REPOSITORY} ${HOME}/bash_history
        cd ${HOME}/bash_history
        git checkout -b "${BASH_HISTORY_BRANCH}"
        git push -u origin "${BASH_HISTORY_BRANCH}"
    fi
	cd ${HOME}/bash_history
    cp ${HOME}/.bash_history ${HOME}/bash_history/bash_history
    git add bash_history
    git commit -am `date +%Y-%m-%d_%H.%M.%S`
    git push
    echo -n "" > ${DIR}/bash_aliases_local_after
	echo "##### History #####" >> ${DIR}/bash_aliases_local_after
	echo "HISTFILE=${HOME}/bash_history/bash_history" >> ${DIR}/bash_aliases_local_after
	echo "" >> ${DIR}/bash_aliases_local_after
	cat ${DIR}/bash_aliases_local_template >> ${DIR}/bash_aliases_local_after	
fi

 

sed -i '/\(HIST\|PROMPT_COMMAND\|hist\|ignoreboth\|ignoredups\|ignorespace\)/ s/^/#/' ${HOME}/.bashrc
sed -i '/\(HIST\|PROMPT_COMMAND\|hist\|ignoreboth\|ignoredups\|ignorespace\)/ s/$/ ### commented out by Bash Historian/' ${HOME}/.bashrc


