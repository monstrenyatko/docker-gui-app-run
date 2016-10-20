#!/bin/bash

HOSTNAME=`hostname`
echo "127.0.0.1 $HOSTNAME" >> /etc/hosts

USERNAME="user"
USER_ID=${LOCAL_USER_ID:-1000}
echo "Starting with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m $USERNAME
export HOME=/home/$USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME

exec /usr/local/bin/gosu $USERNAME "$@"

