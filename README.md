# Bash Historian
##### Eternal Bash history in a github repo and bash aliases

## Installation

* clone public repo and run an install script that
    * backs up your history file if it exists
    * backs up your bash aliases file if it exists
    * backs up your bashrc file if it exists
    * comments out lines with hist, HIST, ignoreboth,ignoredup,ignorespace:ignoredups in your .bashrc and writes, that it is commented out by Bash Historian
    * asks for a private repo to use as a history storage and for a machine name and places them in .bash_aliases_local_before
    * clones a private repo to ${HOME}/bash_history_repo
* setup SSH key access to github (the process should be simplified somehow!)





