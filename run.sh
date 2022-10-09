#!/bin/sh

# The below is modified from https://github.com/activeeos/wireguard-docker

# Найти интерфейс Wireguard

interfaces=`find /etc/wireguard -type f`
if [ -z $interfaces ]; then
    echo "$(date): Interface not found in /etc/wireguard" >&2
    exit 1
fi

start_interfaces() {
    for interface in $interfaces; do
        echo "$(date): Starting Wireguard $interface"
        wg-quick up $interface
    done
}

stop_interfaces() {
    for interface in $interfaces; do
        wg-quick down $interface
    done
}

start_interfaces

# Добавить правило маскировки для NAT-трафика VPN, направляемого в Интернет

if [ $IPTABLES_MASQ -eq 1 ]; then
    echo "Adding iptables NAT rule"
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
fi

# Обработка поведения при выключении
finish () {
    echo "$(date): Shutting down Wireguard"
    stop_interfaces
    if [ $IPTABLES_MASQ -eq 1 ]; then
        iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
    fi

    exit 0
}

trap finish TERM INT QUIT

if [ $WATCH_CHANGES -eq 0 ]; then
    sleep infinity &
    wait $!
else
    while inotifywait -e modify -e create /etc/wireguard; do
        stop_interfaces
        start_interfaces
    done
fi
