FROM alpine

RUN apk add --update --no-cache \
    lighttpd \
    lighttpd-mod_auth \
    curl \
    jq \
    wireguard-tools \
    && rm -rf /var/cache/apk/*

COPY etc/lighttpd/* /etc/lighttpd/
COPY entrypoint.sh /usr/local/bin/

RUN chmod 700 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
