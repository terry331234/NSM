FROM jasonish/suricata:6.0.4

# Copy over the init script.
COPY --chown=root:root ./suricata/init.sh /init.sh
RUN chmod +x /init.sh

# Copy over the update rules script.
COPY --chown=root:root ./suricata/update.sh /update.sh
RUN chmod +x /update.sh

ENTRYPOINT ["/init.sh"]
