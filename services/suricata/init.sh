#!/bin/bash

suricata-update list-sources --enabled | grep snort/community > /dev/null
if [[ $? != 0 ]]; then
    echo "Adding snort community rules"
    suricata-update add-source snort/community https://www.snort.org/downloads/community/community-rules.tar.gz
fi

echo "Updating rules"
suricata-update update-sources
suricata-update --no-test
exec /bin/bash /docker-entrypoint.sh $@