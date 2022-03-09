#!/bin/bash

if [ ! -d "/var/log/zeek/current" ]; then
    mkdir /var/log/zeek/current
fi

if [[ "${PGID}" -ne "$(id -g zeek)" ]]; then
    echo "Setting zeek group id to $PGID"
    groupmod -o -g "${PGID}" zeek
fi

if [[ "${PUID}" -ne "$(id -u zeek)" ]]; then
    echo "Setting zeek user id to $PUID"
    usermod -o -u "${PUID}" zeek
fi

chown -R zeek:zeek /var/log/zeek
chown -R zeek:zeek /var/log/zeek/current

#fix capture permission, requires addcap option in docker
setcap cap_net_raw,cap_net_admin=eip /usr/local/zeek/bin/zeek
setcap cap_net_raw,cap_net_admin=eip /usr/local/zeek/bin/capstats

/usr/sbin/gosu zeek:zeek /usr/local/zeek/bin/zeek -C local $@
