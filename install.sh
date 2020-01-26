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

	


sed -i '/\(HIST\|PROMPT_COMMAND\|hist\|ignoreboth\|ignoredups\|ignorespace\)/ s/^/#/' ${HOME}/.bashrc
sed -i '/\(HIST\|PROMPT_COMMAND\|hist\|ignoreboth\|ignoredups\|ignorespace\)/ s/$/ ### commented out by Bash Historian/' ${HOME}/.bashrc

echo "" > ${DIR}/.bash_aliases_local_before

cat ${DIR}/.bash_aliases_local_template >> ${DIR}/.bash_aliases_local_before