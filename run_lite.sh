#!/bin/sh

wg-quick up wg0
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

sleep infinity &
wait $!
