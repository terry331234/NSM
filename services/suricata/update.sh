#!/bin/bash
suricata-update update-sources && suricata-update --no-test && suricatasc -c reload-rules
