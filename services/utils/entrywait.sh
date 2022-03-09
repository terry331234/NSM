#!/bin/bash

# Abort on error
set -e

#if [ ! $DEPENDED_HOST ] || [ ! $DEPENDED_PORT ]; then
#    echo "Missing depended host or port!"
#    exit 1
#fi

attempt_counter=0
max_attempts=30

echo "Waiting for depended service"
until $(curl -s -I http://kibana:5601 | grep -q 'HTTP/1.1 302 Found'); do
    if [ ${attempt_counter} -eq ${max_attempts} ]; then
      echo "Max attempts reached, dependent service failed"
      exit 1
    fi
    attempt_counter=$(($attempt_counter+1))
    sleep 2
done

echo "Dependent service is up"
# Run the main container command.
exec "$@"
