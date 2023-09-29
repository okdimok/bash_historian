#!/bin/bash
cmd=$1
[[ -z $cmd ]] && cmd=/bin/bash
echo -e "\07" # bell
nsslack "" "▶ Your new interactive job <code>$cmd</code> has just started on <code>$(hostname)</code>"
$cmd