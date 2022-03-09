FROM zeekurity/zeek:4.1.1

RUN /usr/local/zeek/bin/zkg install --force ja3 hassh

# Install extra package for container/setcap
RUN apt-get update && \
        apt-get install -y tini gosu libcap2-bin

# Create Zeek User.
RUN groupadd --gid 1000 zeek  && \
    adduser --uid 1000 --gid 1000 \
    --home /usr/local/zeek --no-create-home --disabled-password --gecos "" zeek

VOLUME "/var/log/zeek"

# Fix perms
RUN chown -R zeek:zeek /usr/local/zeek

# Copy zeek default config
#COPY --chown=zeek:zeek ./zeek/config/local.zeek /usr/local/zeek/share/zeek/site/local.zeek

# Copy over the entry script.
COPY --chown=root:root ./zeek/entrypoint.sh /usr/local/sbin/entrypoint.sh
RUN chmod +x /usr/local/sbin/entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/sbin/entrypoint.sh"]
