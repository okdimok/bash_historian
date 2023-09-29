#!/usr/bin/env bash
# check out this tutorial
# https://api.slack.com/messaging/webhooks
cmd=$1
[[ -z $cmd ]] && cmd=/bin/bash
echo -e "\07" # bell
txt="▶ Your new interactive job \`${cmd}\` has just started on \`$(hostname)\`"
echo "$txt"
curl -X POST -H 'Content-type: application/json' --data '{"text":"'"${txt}"'"}' "${SLACK_HOOK_ENDPOINT}"
