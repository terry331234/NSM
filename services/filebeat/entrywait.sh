#!/bin/bash

attempt_counter=0
max_attempts=30

# ensure correct permission
chmod go-w /usr/share/filebeat/filebeat.yml
chmod -R go-w /usr/share/filebeat/modules.d

# first time setup
CONTAINER_INITED="script/CONTAINER_INITED"
if [ ! -e $CONTAINER_INITED ]; then
  echo "Doing first time setup for Kibana"

  attempt_counter=0
  echo "Trying to connect to Kibana..."
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
  disableResult=$(curl -s -u elastic:${ELASTICSEARCH_PASSWORD} --location --request PUT 'kibana:5601/api/spaces/space/default' \
    --header 'kbn-xsrf: reporting' \
    --header 'Content-Type: application/json' \
    --data-raw '{
      "id": "default",
      "name": "default",
      "disabledFeatures": ["enterpriseSearch", "ml", "logs", "infrastructure", "apm", "uptime", "observabilityCases", "siem", "fleet", "osquery", "monitoring"]
    }')

  disabledCount=$(echo $disableResult | jq -r '.disabledFeatures' | jq length)

  filebeat setup --dashboards --modules suricata,zeek


  echo "Adding community_id related search link"
  # Add search link runtime field 'search_community_id'
  addLinkResult=$(curl -s -u elastic:${ELASTICSEARCH_PASSWORD} --location --request POST 'kibana:5601/api/index_patterns/index_pattern/filebeat-*/runtime_field' \
    --header 'kbn-xsrf: reporting' \
    --header 'Content-Type: application/json' \
    --data-raw '{
    "name": "search_community_id",
      "runtimeField": {
          "type": "keyword",
          "script": {
              "source": "if (doc['\''network.community_id'\''].size() == 0 ) {\r\n    emit(\"\");\r\n    return;\r\n}\r\ndef cid = doc['\''network.community_id'\''].value;\r\ndef link = \"kibana#/dashboard/b968aa40-b725-11ec-8557-1b440f769a60?_g=(filters:!(('\''$state'\'':(store:globalState),meta:(alias:!n,disabled:!f,index:'\''filebeat-*'\'',key:network.community_id,negate:!f,params:(query:'\''\" + cid + \"'\''),type:phrase),query:(match_phrase:(network.community_id:'\''\" + cid + \"'\'')))),refreshInterval:(pause:!t,value:0),time:(from:'\''\"\r\n+ doc['\''@timestamp'\''].value.minusMinutes(15)\r\n+ \"'\'',mode:quick,to:'\''\" + doc['\''@timestamp'\''].value.plusMinutes(15) + \"'\''))\";\r\n\r\nemit(link);"
          }
      }
  }')

  echo "Adding related metadata search link"
  # Add search link runtime field 'search_session_id'
  addLinkResult=$(curl -s -u elastic:${ELASTICSEARCH_PASSWORD} --location --request POST 'kibana:5601/api/index_patterns/index_pattern/filebeat-*/runtime_field' \
    --header 'kbn-xsrf: reporting' \
    --header 'Content-Type: application/json' \
    --data-raw '{
    "name": "search_session_id",
      "runtimeField": {
          "type": "keyword",
          "script": {
              "source": "if (doc['\''zeek.session_id'\''].size() == 0 ) {\r\n    emit(\"\");\r\n    return;\r\n}\r\ndef sid = doc['\''zeek.session_id'\''].value;\r\ndef link = \"kibana#/dashboard/11d8c090-bcab-11ec-b18c-132531e841f5?_g=(filters:!(('\''$state'\'':(store:globalState),meta:(alias:!n,disabled:!f,index:'\''filebeat-*'\'',key:zeek.session_id,negate:!f,params:(query:'\''\" + sid + \"'\''),type:phrase),query:(match_phrase:(zeek.session_id:'\''\" + sid + \"'\'')))),refreshInterval:(pause:!t,value:0),time:(from:'\''\"\r\n+ doc['\''@timestamp'\''].value.minusMinutes(15)\r\n+ \"'\'',mode:quick,to:'\''\" + doc['\''@timestamp'\''].value.plusMinutes(15) + \"'\''))\";\r\n\r\nemit(link);"
          }
      }
  }')

  # Set search_community_id,search_session_id and ip field format
  addFormatResult=$(curl -s -u elastic:${ELASTICSEARCH_PASSWORD} --location --request POST 'kibana:5601/api/index_patterns/index_pattern/filebeat-*/fields' \
    --header 'kbn-xsrf: reporting' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "fields": {
            "search_community_id": {
                "count": 0,
                "format": {
                    "id": "url",
                    "params": {
                        "urlTemplate": "{{ rawValue }}",
                        "labelTemplate": "Find Related Logs"
                    }
                }
            },
            "source.ip": {
                "count": 0,
                "format": {
                    "id": "url",
                    "params": {
                        "urlTemplate": "https://talosintelligence.com/reputation_center/lookup?search={{ value }}",
                        "labelTemplate": "{{ value }}"
                    }
                }
            },
            "destination.ip": {
                "count": 0,
                "format": {
                    "id": "url",
                    "params": {
                        "urlTemplate": "https://talosintelligence.com/reputation_center/lookup?search={{ value }}",
                        "labelTemplate": "{{ value }}"
                    }
                }
            },
            "search_session_id": {
                "count": 0,
                "format": {
                  "id": "url",
                  "params": {
                      "urlTemplate": "{{ rawValue }}",
                      "labelTemplate": "Find Related Metadata Logs",
                      "openLinkInCurrentTab": true
                  }
                }
            }
        }
    }')

  #check disabled, added field
  #Find Related Logs - part of format option
  #dashboard ids - part of runtime field scripts
  if [[ "$addFormatResult" == *"Find Related Logs"* && "$addFormatResult" == *"11d8c090-bcab-11ec-b18c-132531e841f5"* && "$addFormatResult" == *"b968aa40-b725-11ec-8557-1b440f769a60"* && $disabledCount -eq 11 ]];
    then
      touch $CONTAINER_INITED
      echo "Kibana first time setup complete"
    else
      echo "Kibana first time setup failed"
  fi
fi

# Run the main container command.
exec "$@"
