#!/usr/bin/env bash

function __bh_fetch_all() {
    git branch -r | grep -v '\->' | while read remote; do
        git branch --track "${remote#origin/}" "$remote";
    done
    git fetch --all
    git pull --all
}

function __bh_from_branch() {
    branch=$1;
    git show $branch:bash_history
}

function __bh_all() {
    __tmp=`mktemp`
    git branch -r | grep -v '\->' | while read remote; do
        branch="${remote#origin/}"
        # this requires awk from gawk package and not mawk. One can just install it using apt
        git show $branch:bash_history | awk '{ sub(/^#[0-9]*/, strftime("# %Y-%m-%d %H:%M:%S", substr($1,2))); print; }' | sed -e "s=^=${branch} =" >> $__tmp
    done
    less ${__tmp}
    rm ${__tmp}
}

function __bh_push() {
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

function __register_all_bash_historian_commands () {
  funcs=( bh_fetch_all bh_from_branch bh_all bh_push )
  for f in "${funcs[@]}"; do
    eval "\
    function ${f} {\
      __wrap_to_dir __${f} \"${HOME}/.bash_history_repo/\"; \
    }";
done;
}

