#!/bin/bash

attempt_counter=0
max_attempts=30

echo "Waiting for Kibana"
until $(curl -s -I http://kibana:5601 | grep -q 'HTTP/1.1 302 Found'); do
    if [ ${attempt_counter} -eq ${max_attempts} ]; then
      echo "Max attempts reached, dependent service failed"
      exit 1
    fi
    attempt_counter=$(($attempt_counter+1))
    sleep 2
done

echo "Dependent service is up"


CONTAINER_INITED="script/CONTAINER_INITED"
if [ ! -e $CONTAINER_INITED ]; then
  echo "Doing first time setup for Kibana"

  chmod go-w /usr/share/filebeat/filebeat.yml
  chmod -R go-w /usr/share/filebeat/modules.d

  attempt_counter=0
  until $(curl -s -u elastic:${ELASTICSEARCH_PASSWORD} --location --request GET 'kibana:5601/api/spaces/space/default' | grep -q 'disabledFeatures'); do
      if [ ${attempt_counter} -eq ${max_attempts} ]; then
        echo "Max attempts reached, first time setup failed!"
        exit 1
      fi
      attempt_counter=$(($attempt_counter+1))
      sleep 2
  done

  # Disable total 11 features
  echo "Disabling Unused Kibana Features"
  curl -s -u elastic:${ELASTICSEARCH_PASSWORD} --location --request PUT 'kibana:5601/api/spaces/space/default' \
    --header 'kbn-xsrf: reporting' \
    --header 'Content-Type: application/json' \
    --data-raw '{
      "id": "default",
      "name": "default",
      "disabledFeatures": ["enterpriseSearch", "ml", "logs", "infrastructure", "apm", "uptime", "observabilityCases", "siem", "fleet", "osquery", "monitoring"]
    }'

  # ReCheck result disabled kibana features
  disabledCount=$(curl -s -u elastic:${ELASTICSEARCH_PASSWORD} --location --request GET 'kibana:5601/api/spaces/space/default' | jq -r '.disabledFeatures' | jq length)

  if [ $disabledCount -ne 11 ];
  then
    echo "Kibana first time setup failed"
  else
    touch $CONTAINER_INITED
    echo
    echo "Kibana first time setup complete"
  fi

fi

# Run the main container command.
exec "$@"
