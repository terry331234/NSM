#!/bin/bash

setcap cap_net_raw,cap_net_admin=eip /usr/local/zeek/bin/zeek
setcap cap_net_raw,cap_net_admin=eip /usr/local/zeek/bin/capstats

#copy default config to volume
#default="/usr/local/zeek/share/zeek/site/local.zeek.dist"
config="/usr/local/zeek/share/zeek/site/local.zeek"
#if ! test -e "${config}"; then
#    echo "Creating ${config}"
#    cp -a "${default}" "${config}"
#    chown zeek:zeek "${config}"
#    chown zeek:zeek /var/log/zeek
#fi

if [ ! -d "/var/log/zeek/current" ]; then
    mkdir /var/log/zeek/current
fi

chown zeek:zeek "${config}" /var/log/zeek /var/log/zeek/current

command='/usr/local/zeek/bin/zeek -C -i eth0 local'
/usr/sbin/gosu zeek /usr/local/zeek/bin/zeek -C local $@
