FROM jasonish/suricata:6.0.4

# Copy over the init script.
COPY --chown=root:root init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]
