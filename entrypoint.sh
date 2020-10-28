#!/bin/bash

SERVER_PROT="5180"
SERVER_KEY="0729EF6296854384B5ABD2ECB9335016"
SERVER_URL="https://c.qishi.vip"

_md5(){
    echo -n $1 | md5sum | cut -d ' ' -f 1;
}

_upper(){
    echo -n $1 | tr "[a-z]" "[A-Z]";
}

_rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
    echo $(($num%$max+$min))
}

_rand_str(){
    str=$(_rand 100000000000 999999999999)
    echo -n $str | md5sum | cut -d ' ' -f 1;
}

_setcon(){
    sed -i '/'$1'/d' /etc/config/entrypoint.ini
    if [ "$2" != "" ];then
        echo "$1=$2" >> /etc/config/entrypoint.ini
    fi
}

_getcon(){
    STRING=$(sed '/^'$1'=/!d;s/.*=//' /etc/config/entrypoint.ini)
    echo -n "$STRING"
}

########################################################################
########################################################################
########################################################################

wireguard() {
    mkdir /etc/wireguard
    cd /etc/wireguard
    wg genkey | tee sprivatekey | wg pubkey >spublickey
    wg genkey | tee cprivatekey | wg pubkey >cpublickey
    s1=$(cat sprivatekey)
    s2=$(cat spublickey)
    c1=$(cat cprivatekey)
    c2=$(cat cpublickey)
    eth=$(ls /sys/class/net | grep ^e | head -n1)
    serverip=$(curl ipv4.icanhazip.com)
    port=51820
    chmod 777 -R /etc/wireguard

    cat >/etc/wireguard/server.conf <<-EOF
[Interface]
PrivateKey = $s1
Address = 10.88.0.1/24
PostUp   = iptables -A FORWARD -i server -j ACCEPT; iptables -A FORWARD -o server -j ACCEPT; iptables -t nat -A POSTROUTING -o $eth -j MASQUERADE
PostDown = iptables -D FORWARD -i server -j ACCEPT; iptables -D FORWARD -o server -j ACCEPT; iptables -t nat -D POSTROUTING -o $eth -j MASQUERADE
ListenPort = $port
DNS = 8.8.8.8
MTU = 1420
[Peer]
PublicKey = $c2
AllowedIPs = 10.88.0.2/32
EOF

    cat >/etc/wireguard/client_server <<-EOF
[Interface]
PrivateKey = $c1
Address = 10.88.0.2/24
DNS = 8.8.8.8
MTU = 1420
[Peer]
PublicKey = $s2
Endpoint = $serverip:$port
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF
    wg-quick down server
    wg-quick up server

    wgkey=$(_rand_str)
    cat > /etc/wireguard/wgkey <<-EOF
$wgkey
EOF

    str1="ip=${serverip}&key=${wgkey}&port=${SERVER_PROT}&ssl=0"
    str2="${str1}&${SERVER_KEY}"
    sign=$(_upper $(_md5 $str2))
    curl "${SERVER_URL}/api/publish/server?${str1}&sign=${sign}"
}

lighttpd() {
    chmod a+w /dev/pts/0
    exec lighttpd -D -f /etc/lighttpd/lighttpd.conf
}

entrypoint() {
    wg-quick up server
    wg show
    tail -f /dev/null
}

########################################################################
########################################################################
########################################################################

if [ -z "$(_getcon WGKEY)" ]; then
    WGKEY=$(_rand_str)
    _setcon WGKEY "$WGKEY"
    wireguard
    lighttpd
fi

entrypoint


