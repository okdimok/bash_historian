#!/usr/bin/env bash

host=$1

[[ -z $host ]] && echo Specify host. Note it is also used in scp, so non-standard port numbers are not supported yet. && exit 1;
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ssh $host "rm -rf ~/bash_historian; cp ~/.bashrc.bash_historian.bak ~/.bashrc; cp ~/.bash_aliases.bash_historian.bak ~/.bash_aliases; rm -rf ~/.bash_history_repo;"
