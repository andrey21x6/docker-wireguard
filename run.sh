#!/bin/sh

# The below is modified from https://github.com/activeeos/wireguard-docker

# Найти интерфейс Wireguard

interfaces=`find /etc/wireguard -type f`
if [ -z $interfaces ]; then
    exit 1
fi

start_interfaces() {
    for interface in $interfaces; do
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
    iptables -t nat -A POSTROUTING -o $PHYSICAL_INTERFACE_LAN -j MASQUERADE
	iptables -A FORWARD -i wg0 -j ACCEPT
fi

# Обработка поведения при выключении

finish () {
    stop_interfaces
    if [ $IPTABLES_MASQ -eq 1 ]; then
        iptables -t nat -D POSTROUTING -o $PHYSICAL_INTERFACE_LAN -j MASQUERADE
		iptables -D FORWARD -i wg0 -j ACCEPT
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
