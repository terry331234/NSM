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

chown zeek:zeek "${config}"
chown zeek:zeek /var/log/zeek

runuser zeek -g zeek -c `/usr/local/zeek/bin/zeek -C local $@`
sleep infinity
