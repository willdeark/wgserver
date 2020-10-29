#!/bin/sh

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
    sed -i '/'$1'/d' /usr/local/bin/entrypoint.ini
    if [ "$2" != "" ];then
        echo "$1=$2" >> /usr/local/bin/entrypoint.ini
    fi
}

_getcon(){
    STRING=$(sed '/^'$1'=/!d;s/.*=//' /usr/local/bin/entrypoint.ini)
    echo -n "$STRING"
}

_generatesign() {
    JSON_STRING=$1
    list=$(echo $JSON_STRING | jq -S);
    length=$(echo $JSON_STRING | jq -S 'length');
    string=""
    for index in $(seq 0 $length)
    do
        if [ "$index" -lt "$length" ]; then
            key=$(echo $list | jq -r '.|keys['${index}']')
            val=$(echo $list | jq -r '.'${key})
            if [ "$key" != "sign" ]; then
                string=${string}${key}'='${val}'&'
            fi
        fi
    done
    str2=${string}$(_getcon APIKEY)
    sign=$(_upper $(_md5 $str2))
    echo "$sign"
}

########################################################################
########################################################################
########################################################################

wireguard_user_add(){
    client=$1
    cd /etc/wireguard/
    if [ ! -f "/etc/wireguard/client_${client}" ]; then
        cp client_server "client_${client}"
        wg genkey | tee temprikey | wg pubkey > tempubkey
        ipnum=$(grep Allowed /etc/wireguard/server.conf | tail -1 | awk -F '[ ./]' '{print $6}')
        newnum=$(expr ${ipnum} + 1)
        if [ ${newnum} -gt 254 ]; then
            echo -e '{"ret":0,"msg":"Insufficient IP address","data":{}}'
            exit 0
        fi
        sed -i 's%^PrivateKey.*$%'"PrivateKey = $(cat temprikey)"'%' "client_${client}"
        sed -i 's%^Address.*$%'"Address = 10.88.0.$newnum\/24"'%' "client_${client}"
        cat >> /etc/wireguard/server.conf <<-EOF
[Peer]
PublicKey = $(cat tempubkey)
AllowedIPs = 10.88.0.$newnum/32
EOF
        chmod 600 "/etc/wireguard/client_${client}"
        wg-quick down server
        wg-quick up server
        rm -f temprikey tempubkey
        config=$(cat "/etc/wireguard/client_${client}" | sed ':label;N;s/\n/[br]/;b label')
        echo -e '{"ret":1,"msg":"success","data":{"PrivateKey":"'$(wireguard_user_config PrivateKey $client)'","Address":"'$(wireguard_user_config Address $client)'","DNS":"'$(wireguard_user_config DNS $client)'","MTU":"'$(wireguard_user_config MTU $client)'","PublicKey":"'$(wireguard_user_config PublicKey $client)'","AllowedIPs":"'$(wireguard_user_config AllowedIPs $client)'","Endpoint":"'$(wireguard_user_config Endpoint $client)'","PersistentKeepalive":"'$(wireguard_user_config PersistentKeepalive $client)'","config":"'${config}'"}}'
    else
        echo -e '{"ret":0,"msg":"Client already exists","data":{}}'
    fi
}

wireguard_user_remove(){
    client=$1
    client_if="/etc/wireguard/client_${client}"
    default_if="/etc/wireguard/server.conf"
    if [ ! -s "${client_if}" ]; then
        echo -e '{"ret":0,"msg":"Client not exists","data":{}}'
        exit 0
    fi
    tmp_tag="$(grep -w "Address" ${client_if} | awk '{print $3}' | cut -d\/ -f1 )"
    [ -n "${tmp_tag}" ] && sed -i '/'"$tmp_tag"'\//d;:a;1,2!{P;$!N;D};N;ba' ${default_if}
    wg-quick down server
    wg-quick up server
    rm -f ${client_if}
    echo -e '{"ret":1,"msg":"success","data":{}}'
}

wireguard_user_config(){
    client_if="/etc/wireguard/client_${client}"
    echo -e $(sed -n -e 's/^\s*'$1'\s*=\s*//p' "$client_if")
}