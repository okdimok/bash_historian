#!/usr/bin/env bash

function __fetch_all_branches() {
    git branch -r | grep -v '\->' | while read remote; do
        git branch --track "${remote#origin/}" "$remote";
    done
    git fetch --all
    git pull --all
}

function __get_history_from_branch() {
    branch=$1;
    git show $branch:bash_history
}

function __get_history_from_all_branches() {
    __tmp=`mktemp`
    git branch -r | grep -v '\->' | while read remote; do
        branch="${remote#origin/}"
        git show $branch:bash_history >> $__tmp
    done
    less ${__tmp}
    rm ${__tmp}
}

function __update_current_branch() {
    git add bash_history
    git commit -m $(date +%Y-%m-%d_%H.%M.%S)
    git push
}

function __wrap_to_dir() {
  WRAPPED=$1
  TARGET=$2
  D=${PWD}
  cd $2
  $1
  cd ${D}
}


funcs=( fetch_all_branches get_history_from_branch get_history_from_all_branches update_current_branch )
for f in "${funcs[@]}"; do
  eval "\
  function ${f} {\
    __wrap_to_dir __${f} \"${HOME}/.bash_history_repo/\"; \
  }";
done;

