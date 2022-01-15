FROM zeekurity/zeek:4.1.1

# Install extra zeek packages
RUN apt-get update && \
    apt-get install -y cmake build-essential libssl-dev libpcap-dev libcap2-bin && \
    /usr/local/zeek/bin/zkg install --force ja3 hassh zeek-community-id

# Create Zeek User.
RUN groupadd --gid 998 zeek  && \
    adduser --uid 998 --gid 998 \
    --home /usr/local/zeek --no-create-home --disabled-password --gecos "" zeek

VOLUME "/var/log/zeek"

# Fix perms
RUN chown -R zeek:zeek /usr/local/zeek && \
    chown zeek:zeek var/log/zeek

# Copy communityID script
COPY --chown=zeek:zeek  files/communityid.zeek /usr/local/zeek/share/zeek/policy/custom/communityid.zeek

# Copy zeek default config
COPY --chown=zeek:zeek files/local.zeek /usr/local/zeek/share/zeek/site/local.zeek

# Copy over the entry script.
COPY --chown=zeek:zeek files/zeek.sh /usr/local/sbin/zeek.sh
RUN chmod +x /usr/local/sbin/zeek.sh

ENTRYPOINT ["/usr/local/sbin/zeek.sh"]
