# Bash Historian
##### Eternal Bash history in a github repo and bash aliases

## Installation

You should clone public repo and run an install script that
* backs up your history file if it exists
* backs up your bash aliases file if it exists
* backs up your bashrc file if it exists
* creates 
* comments out lines with hist, HIST, ignoreboth,ignorespace,ignoredups in your .bashrc and writes, that it is commented out by Bash Historian
* clones a private repo to ${HOME}/bash_history_repo, specified branch, 
* copies history to it.bash_aliases_local_before, pushes to specified branch
* sets up automatic pushes in crontab if requested

Parameters it needs:
* which private repo to check
* which SSH key to use to push, or how to generate one
* branch name for this machine

`AVOID_COMPLETE_BH_INSTALL` — set this variable in the install.sh script env to avoid complete installation.
such as
`AVOID_COMPLETE_BH_INSTALL=1 source ${HOME}/bash_historian/install.sh`







