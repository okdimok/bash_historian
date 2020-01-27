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

function __install_gitconfig() {
  if [[ -n $INSTALL_GITCONFIG ]]; then
    [[ -n "${GIT_USER_NAME}" || -n "${GIT_USER_EMAIL}" ]]  && echo "[user]" >  ${HOME}/.gitconfig
    [[ -n "${GIT_USER_NAME}" ]] && echo -e "\tname = '${GIT_USER_NAME}'" >>  ${HOME}/.gitconfig
    [[ -n "${GIT_USER_EMAIL}" ]] && echo -e "\temail = '${GIT_USER_EMAIL}'" >>  ${HOME}/.gitconfig
    cat ${DIR}/gitconfig_template >> ${HOME}/.gitconfig
  fi
}

function __check_github_ssh_access() {
    [[ `bash -c "ssh -o BatchMode=yes -q git@github.com" 2>&1 | grep ^Hi | wc -l` -gt 0 ]]
}

function __generate_git_ssh_key() {
   echo generating a ssh-key for you
   ssh-keygen -t ed25519 -f ${DIR}/ssh_key
   ssh-add ${DIR}/ssh_key
   HTTPS_REPO="${BASH_HISTORY_REPOSITORY/git@github.com:/https:\/\/github.com\/}"
   HTTPS_REPO="${HTTPS_REPO%.git}"
   echo now you should open 
   echo ${HTTPS_REPO}/settings/keys
   echo and add there a public key
   echo ====================
   cat ${DIR}/ssh_key.pub
   echo ====================
   read -n 1 -p "Press Enter when ready": __no_need
   __check_github_ssh_access
}

function __install_git_ssh_key() {
  if [[ -n $BASH_HISTORY_SSH_KEY ]]; then
    echo $BASH_HISTORY_SSH_KEY > ${DIR}/ssh_key
  fi
   
  [[ -f ${DIR}/ssh_key ]] && ssh-add ${DIR}/ssh_key
    
  if __check_github_ssh_access; then
    return 0;
  fi
  
  if [[ -n $BASH_HISTORY_SSH_KEY ]]; then
     echo "==WARNING== You have specified a key, but it is not accepted in your repo"
  else
    while ! __generate_git_ssh_key; do
      echo -n "";
    done;
  fi
  

  
}

##### Actual Operations
__bak_file ${HOME}/.bashrc
__bak_file ${HOME}/.bash_aliases
__bak_file ${HOME}/.bash_history
# this outputs a HISTFILE to a file
__tmp=$(mktemp)
bash -ic "source ${HOME}/.bashrc && set | grep \"^HISTFILE=\" > ${__tmp}"
HF=`cat "${__tmp}"`
HF="${HF#*=}"
__bak_file "${HF}"
[[ -z $HF ]] && HF=${HOME}/.bash_history

cp ${DIR}/home_bash_aliases_template ${HOME}/.bash_aliases

if [[ ! -f ${DIR}/install_configuration ]]; then
	cp ${DIR}/install_configuration_template ${DIR}/install_configuration
	echo "Please edit ${DIR}/install_configuration to set the history repository. It has been created from a template."
	exit 0;
fi;

source ${DIR}/install_configuration

[[ -z $BASH_HISTORY_TEMPLATE_EDITED ]] && echo "You have not edited BASH_HISTORY_TEMPLATE_EDITED var. Please edit ${DIR}/install_configuration to set the history repository. It has been created from a template." && exit 1 || echo "Loaded proper config from ${DIR}/install_configuration";

__install_gitconfig

__install_git_ssh_key

if [[ ! -z $BASH_HISTORY_REPOSITORY ]]; then
    
    BASH_HISTORY_LOCAL_REPO="${HOME}/.bash_history_repo"
    __cmd="git clone";
    [[ ! -z $BASH_HISTORY_BRANCH ]] && __cmd="${__cmd} --branch ${BASH_HISTORY_BRANCH}"
    __cmd="${__cmd} ${BASH_HISTORY_REPOSITORY} ${BASH_HISTORY_LOCAL_REPO}"
    eval "${__cmd}" && BRANCH_FOUND=1
    if [[ -z $BRANCH_FOUND ]]; then
        git clone ${BASH_HISTORY_REPOSITORY} ${BASH_HISTORY_LOCAL_REPO}
        cd ${BASH_HISTORY_LOCAL_REPO}
        git checkout -b "${BASH_HISTORY_BRANCH}"
        git push -u origin "${BASH_HISTORY_BRANCH}"
    fi
	cd ${BASH_HISTORY_LOCAL_REPO}
    cp ${HF} ${BASH_HISTORY_LOCAL_REPO}/bash_history
    git add bash_history
    git commit -am `date +%Y-%m-%d_%H.%M.%S`
    git push
    echo -n "" > ${DIR}/bash_aliases_local_after
	echo "##### History #####" >> ${DIR}/bash_aliases_local_after
	echo "HISTFILE=${BASH_HISTORY_LOCAL_REPO}/bash_history" >> ${DIR}/bash_aliases_local_after
	echo "" >> ${DIR}/bash_aliases_local_after
	cat ${DIR}/bash_aliases_local_template >> ${DIR}/bash_aliases_local_after	
fi

 

sed -i '/\(HIST\|PROMPT_COMMAND\|hist\|ignoreboth\|ignoredups\|ignorespace\)/ s/^/#/' ${HOME}/.bashrc
sed -i '/\(HIST\|PROMPT_COMMAND\|hist\|ignoreboth\|ignoredups\|ignorespace\)/ s/$/ ### commented out by Bash Historian/' ${HOME}/.bashrc


