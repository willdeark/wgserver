FROM sebdanielsson/wireguard-server

ENV LIGHTTPD_VERSION=1.4.55-r1

RUN apk add --update --no-cache \
	lighttpd=${LIGHTTPD_VERSION} \
	lighttpd-mod_auth \
  && apk add curl \
  && rm -rf /var/cache/apk/*

COPY start.sh /usr/local/bin/

CMD ["start.sh"]