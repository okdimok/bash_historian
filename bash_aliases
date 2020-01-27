DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/bash_colors

echo -e "$BGreen""Bash Historian Enabled Shell""$Color_Off"

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
# HISTFILE=${DIR}/bash_history
HISTFILE=${HOME}/.bash_history # keeping it for now to allow public repo

##### Aliases #####

alias tmux_main="tmux a -d -t main || tmux new -A -s main"

ssh_tmux () {
    host=$1
    shift
    ssh $host -t "tmux a -d -t main || tmux new -A -s main" $@
}

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

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias rsync_ai='rsync -av --info=progress2'
alias pycharm="nohup pycharm-professional . > /dev/null 2>&1 &"

function date_files() {
	date +%Y-%m-%d_%H.%M.%S
}
##### Environments
PREV_PS="${debian_chroot:+($debian_chroot)}\[${Green}\]\u@\h\[${Color_Off}\]:\[${ICyan}\]\w\[${Color_Off}\]"
PREV_PS="${PS1:0: -3}"
source /etc/bash_completion.d/git-prompt
export PS1="${PREV_PS}"'$(__git_ps1 "\[${BYellow}\](%s)")'"\[${Color_Off}\]\$ "

PAGER=vless
GIT_PAGER=vless
LESS=FRX
LESS=-Ri

export NO_AT_BRIDGE=1 # to prevent gvim warnings and other stuff


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

##### To Override Locally #####
# this is going to be the local file to control the local policies
if [ -f ${DIR}/bash_aliases_local_after ]; then
    . ${DIR}/bash_aliases_local_after
fi




