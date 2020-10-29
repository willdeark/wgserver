#!/usr/bin/env bash

COMPOSE="docker-compose"


_inityml() {
    json=$(cat config.json | jq)
    list=$(echo $json | jq -S '.wireguard')
    length=$(echo $json | jq -S '.wireguard|length')
    CONSOLE_URL=$(echo $json | jq -r '.console.url')
    CONSOLE_KEY=$(echo $json | jq -r '.console.key')

    cat > docker-compose.yml <<-EOF
version: '3'
services:
EOF
    for index in $(seq 0 $length)
    do
        if [ "$index" -lt "$length" ]; then
            NAME=$(echo $list | jq -r ".[$index].name")
            SERVER_IP=$(echo $list | jq -r ".[$index].server_ip")
            SERVER_PORT=$(echo $list | jq -r ".[$index].server_port")
            HTTP_PROT=$(echo $list | jq -r ".[$index].http_prot")
            cat >> docker-compose.yml <<-EOF
  $NAME:
    container_name: $NAME
    image: kuaifan/lws
    privileged: true
    restart: always
    tty: true
    sysctls:
      - 'net.ipv4.ip_forward=1'
    ports:
      - "$HTTP_PROT:80/tcp"
      - '$SERVER_PORT:$SERVER_PORT/udp'
    environment:
      - "CONSOLE_URL=${CONSOLE_URL}"
      - "CONSOLE_KEY=${CONSOLE_KEY}"
      - "SERVER_IP=$SERVER_IP"
      - "SERVER_PORT=$SERVER_PORT"
      - "HTTP_PROT=$HTTP_PROT"
    volumes:
      - './etc/www:/www'
      - './etc/lighttpd/:/etc/lighttpd'
EOF
        fi
    done
}


_inityml

if [ $# -gt 0 ];then
    if [[ "$1" == "restart" ]]; then
        shift 1
        $COMPOSE stop
        $COMPOSE start
    else
        $COMPOSE "$@"
    fi
else
    $COMPOSE ps
fi
