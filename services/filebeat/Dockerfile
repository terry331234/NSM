FROM docker.elastic.co/beats/filebeat:7.17.1

USER root

# Install jq for json parsing
RUN apt-get update && \
    apt-get install -y jq

RUN mkdir script && chown filebeat:filebeat script

USER filebeat

# Copy the entrywait script.
COPY --chown=filebeat:filebeat ./filebeat/entrywait.sh script/entrywait.sh
RUN chmod +x script/entrywait.sh

ENTRYPOINT ["script/entrywait.sh", "/bin/tini", "--", "/usr/share/filebeat/filebeat"]