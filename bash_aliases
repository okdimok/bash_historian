#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/bash_colors

[[ $- == *i* ]] && echo -e "$BGreen""Bash Historian Enabled Shell""$Color_Off"

PS_USER_COLOR=${Green}
PS_HOST_COLOR=${Green}
PS_PATH_COLOR=${BCyan}

##### To Override Locally Before Other Aliases #####
# this is going to be the local file to control the local policies
if [ -f ${DIR}/bash_aliases_local_before ]; then
    . ${DIR}/bash_aliases_local_before
fi

##### History #####
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend
PROMPT_COMMAND='history -a; history -n'

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=
HISTFILESIZE=
HISTTIMEFORMAT="%F %T "
# HISTFILE=${DIR}/bash_history
HISTFILE=${HOME}/.bash_history # keeping it for now to allow public repo

##### Aliases #####

function tmux_main () {
    tmux a -d -t main || tmux new -A -s main
}
export -f tmux_main

ssh_tmux () {
    host=$1
    shift
    ssh $host -t "tmux a -d -t main || tmux new -A -s main" $@
}
export -f ssh_tmux

function gvimm() { gvim "$@" 2>/dev/null ;}
function title {
    echo -en "\033]2;$1\007";
}

function my_screen {
	title $1
	ssh -t $1 screen -R -d
}

function get_instance_ip() {
	gcloud compute instances describe $1 --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
}

function is_installed() {
    if ! dpkg -s $1 >/dev/null 2>&1; then
        if [ -z $2 ]; then
            echo $1 is not installed
        fi
        return 1; # error, stop exec
    else
        if [ -z $2 ]; then
            echo $1 is installed
        fi
        return 0; # OK, continue exec
    fi
}

function __register_all_bash_historian_hidden_commands () {
  source "${HOME}/bash_historian/aux/bash_history_repo_commands.sh"
}

__register_all_bash_historian_hidden_commands
__register_all_bash_historian_commands

function ngc_last_job_id () {
	last_job=`ngc batch list --format_type csv --status RUNNING | grep -v Id | tail -n 1 | cut -d, -f1`
	[[ -z $last_job ]] && >&2 echo "last job has no Id yet" && return 1;
	echo $last_job
}

function ngc_running_info () {
	ngc batch list --format_type csv --status RUNNING | grep -v Id | cut -d, -f1 | while read job_id; do
		ngc batch info $job_id;
	done;
}

function ngc_wait_for_job_and_notify () {
    for i in {1..1500}; do # 1500 times 5 sec ~approx 2 hours
        if ngc_last_job_id; then
            __ngc_info="$(ngc_running_info)"
            nst "Your NGC job started" "${__ngc_info}";
            echo "Your NGC job started"
            echo "${__ngc_info}";
            return 0;
        else
            sleep 5;
        fi;
    done;
    return 1;
}

function last_file_matching () {
    echo $(ls -t ${@:2} | head -n 1)
}

function slurm_wait_n_jobs_left_and_notify(){
    for i in {1..10000}; do # 1500 times 5 sec ~approx 2 hours
        if [[ $1 = $(( $(squeue --me | wc -l) - 1 )) ]]; then
            nst "Only $1 SLURM jobs left" "$(sacct --format="JobID,JobName%30,Partition,Account,AllocCPUS,State,ExitCode" | tail -n 15)";
            echo  "Only $1 SLURM jobs left";
            echo "$(sacct --format="JobID,JobName%30,Partition,Account,AllocCPUS,State,ExitCode" | tail -n 15)";
            return 0;
        else
            sleep 5;
        fi;
    done;
    return 1;
}

alias basic_alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias rsync_ai='rsync -av --info=progress2'
alias pycharm="nohup pycharm-professional . > /dev/null 2>&1 &"

function date_files() {
	date +%Y-%m-%d_%H.%M.%S
}

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias alert_telegram='nst "$([ $? = 0 ] && echo Completed || echo ERROR) $(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')" '




##### Environments
PREV_PS="${debian_chroot:+($debian_chroot)}\[${PS_USER_COLOR}\]\u\[${Color_Off}\]@\[${PS_HOST_COLOR}\]\h\[${Color_Off}\]:\[${PS_PATH_COLOR}\]\w\[${Color_Off}\]"
# PREV_PS="${PS1:0: -3}"
[[ -f ${DIR}/git-prompt.sh ]] && source ${DIR}/git-prompt.sh
command -v __git_ps1 >/dev/null 2>&1 && export PS1="${PREV_PS}"'$(__git_ps1 "\[${BYellow}\](%s)")'"\[${Color_Off}\]\$ " ||  export PS1="${PREV_PS}""\[${Color_Off}\]\$ "

PAGER=vless
GIT_PAGER=vless
LESS=FRX
LESS=-Ri

export NO_AT_BRIDGE=1 # to prevent gvim warnings and other stuff

if [[ ! -S "${SSH_AUTH_SOCK}" ]]; then
    # echo "warn: no forward agent detected ('${SSH_AUTH_SOCK}' is not a socket)";
    export SSH_AUTH_SOCK=~/.ssh/ssh-agent.$HOSTNAME.sock
    ssh-add -l 2>/dev/null >/dev/null
    if [ $? -ge 2 ]; then
        ssh-agent -a "$SSH_AUTH_SOCK" >/dev/null
    fi
fi

##### GLOBAL PATHs #####

export PATH="${HOME}/my_scripts:$PATH"
export PATH="${HOME}/apps:$PATH"

# export PATH="${HOME}/miniconda3/bin:$PATH"
# export PATH="${HOME}/apps/miniconda3/bin:$PATH"
# export PATH="${HOME}/my_scripts:$PATH"
# export PATH="/usr/local/cuda-8.0/bin:$PATH"

# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda-8.0/lib64"
# export CUDA_HOME="/usr/local/cuda-8.0"

export LD_LIBRARY_PATH=.:/lib:/usr/lib:/usr/local/lib

# export J2REDIR=/usr/lib/jvm/java-8-oracle
# export J2SDKDIR=/usr/lib/jvm/java-8-oracle
# export JAVA_HOME=/usr/lib/jvm/java-8-oracle

export QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb 

alias espmake="make -f ~/apps/makeEspArduino/makeEspArduino.mk"
export ARDMK_DIR="/usr/share/arduino/"


##### App Specific Section #####
__register_ngc=""
is_installed python-argcomplete silent &&  eval 'export __register_ngc="eval \"\$(register-python-argcomplete ngc)\""'
eval $__register_ngc
# export DOCKER_HOST=localhost:2375

#. /opt/ros/kinetic/setup.bash
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

##### To Override Locally #####
# this is going to be the local file to control the local policies
if [ -f ${DIR}/bash_aliases_local_after ]; then
    . ${DIR}/bash_aliases_local_after
fi




