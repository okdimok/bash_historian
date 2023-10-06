#!/bin/bash
cmd=$1
[[ -z $cmd ]] && cmd=/bin/bash
echo -e "\07" # bell
nsslack "" "▶ Your new interactive job \`$cmd\` has just started on \`$(hostname)\`"
$cmd
