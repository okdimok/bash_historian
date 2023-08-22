#!/bin/bash

[[ -z $JUPYTER_PORT ]] && JUPYTER_PORT=8000
[[ -z $JUPYTER_TOKEN ]] && JUPYTER_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQSflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
source ~/.bashrc
msg=""
for ip_addr in $(hostname -I)
do
    uri="http://${ip_addr}:${JUPYTER_PORT}/?token=${JUPYTER_TOKEN}";
    echo $uri;
    msg="${msg}<a href='${uri}'>Jupyter @ ${ip_addr}</a> ";
done
hostname 
echo -e "\07" # bell
nst --raw "▶ Your new interactive Jupyter has just started on $(hostname)" "${msg}" 
jupyter lab --ip=0.0.0.0 --port="${JUPYTER_PORT}" \
--allow-root --no-browser \
--NotebookApp.token="${JUPYTER_TOKEN}" \
--NotebookApp.allow_origin='*' --notebook-dir=/