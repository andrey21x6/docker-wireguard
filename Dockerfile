FROM debian:buster

# Добавить репозиторий debian backports для пакетов wireguard
RUN echo "deb http://deb.debian.org/debian/ buster-backports main" > /etc/apt/sources.list.d/buster-backports.list

# Установить пакеты wireguard
RUN apt-get update && \
    apt-get install -y --no-install-recommends wireguard-tools iptables nano net-tools procps openresolv inotify-tools && \
    apt-get clean
    rm -rf /var/lib/apt/lists/*

# Копирование файла из текущей папки в контейнер
COPY ./run.sh /scripts

# Использовать правило iptables masquerade NAT
ENV IPTABLES_MASQ=1

# Следите за изменениями в файлах конфигурации интерфейса (по умолчанию отключено)
ENV WATCH_CHANGES=0

# LAN интерфейс хостовой машины
ENV PHYSICAL_INTERFACE_LAN=enp1s2

EXPOSE 5555/udp

# Обычное поведение - просто запустить wireguard с существующими конфигурациями
ENTRYPOINT ["run.sh"]
