#!/usr/bin/env bash

host=$1
config=$2

[[ -z $host ]] && echo Specify host. Note it is also used in scp, so non-standard port numbers are not supported yet. && exit 1;
[[ -z $config ]] && echo You did not specify the config file, installation will continue in interactive mode;

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

remote_instructions=`cat ${DIR}/aux/remote_install_instructions`

ssh $host "git clone https://github.com/okdimok/bash_historian;"
[[ -n $config ]] && scp ${config} $host:~/bash_historian
ssh -t $host "cd ~/bash_historian; \\
./install.sh; \\
echo \"${remote_instructions}\"; \\
/bin/bash -i"