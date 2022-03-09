FROM docker.elastic.co/beats/filebeat:7.17.1

# Copy the entrywait script.
COPY --chown=filebeat:filebeat ./utils/entrywait.sh /entrywait.sh
RUN chmod +x /entrywait.sh

ENTRYPOINT ["/entrywait.sh", "/bin/tini", "--", "/usr/share/filebeat/filebeat"]