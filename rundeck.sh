#!/bin/bash
#
# rundeckd    Startup script for rundeck
prog="rundeckd"

[ -e /etc/default/$prog ] && . /etc/default/$prog

. /etc/rundeck/profile

cd /var/log/rundeck
exec bash -c "$rundeckd" "${ARGS[@]}"