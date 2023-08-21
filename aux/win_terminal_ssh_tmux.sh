#!/bin/bash -i
SSH_HOSTS=$(grep "Host " ~/.ssh/config | sed "s/.*Host //" | sort | xargs);
echo "${SSH_HOSTS}";
echo -n "user@host: ";
read user_host;
title "${user_host}";
ssh_tmux "${user_host}";