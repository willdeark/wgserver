FROM alpine

ENV LIGHTTPD_VERSION=1.4.55-r1

RUN apk add --update --no-cache \
	lighttpd=${LIGHTTPD_VERSION} \
	lighttpd-mod_auth \
  && apk add curl \
  && apk --no-cache --virtual add wireguard-tools \
  && rm -rf /var/cache/apk/*

COPY etc/lighttpd/* /etc/lighttpd/
COPY start.sh start.sh

RUN chmod 700 /start.sh

#ENTRYPOINT [ "/start.sh entry" ]
CMD ["/start.sh"]