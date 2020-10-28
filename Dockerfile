FROM alpine

ENV LIGHTTPD_VERSION=1.4.55-r1

RUN apk add --update --no-cache \
	lighttpd=${LIGHTTPD_VERSION} \
	lighttpd-mod_auth \
  && apk add curl \
  && apk add jq \
  && apk --no-cache --virtual add wireguard-tools \
  && rm -rf /var/cache/apk/*

COPY etc/lighttpd/* /etc/lighttpd/
COPY entrypoint.sh /usr/local/bin/

RUN chmod 700 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
