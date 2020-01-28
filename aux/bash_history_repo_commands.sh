#!/usr/bin/env bash

function fetch_all_branches() {
    git branch -r | grep -v '\->' | while read remote; do
        git branch --track "${remote#origin/}" "$remote";
    done
    git fetch --all
    git pull --all
}

function get_history_from_branch() {
    branch=$1;
    git show $branch:bash_history
}

function get_history_from_all_branches() {
    __tmp=`mktemp`
    git branch -r | grep -v '\->' | while read remote; do
        branch="${remote#origin/}"
        git show $branch:bash_history >> $__tmp
    done
    less ${__tmp}
    rm ${__tmp}
}

function update_current_branch() {
    git add bash_history
    git commit -m $(date +%Y-%m-%d_%H.%M.%S)
    git push
}

function update_repo_commands_from_master() {
    read -n 1 -p "Make sure you are not executing it on a working copy. To continue press any key"
    fetch_all_branches
    git branch -r | grep -v '\->' | grep -v 'origin/master' | while read remote; do
        branch="${remote#origin/}"
        git checkout $branch
        git show master:repo_commands.sh > repo_commands.sh
        git add repo_commands.sh
        git commit -m "repo commands update "$(date +%Y-%m-%d_%H.%M.%S)
        git push
    done
}
