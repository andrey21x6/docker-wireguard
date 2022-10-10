FROM debian:buster

# Добавить репозиторий debian backports для пакетов wireguard и Установить пакеты wireguard
RUN echo "deb http://deb.debian.org/debian/ buster-backports main" > /etc/apt/sources.list.d/buster-backports.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends wireguard-tools iptables net-tools && \
    apt-get clean

# Задаёт текущую директорию в контейнере
WORKDIR /scripts

# Добавить каталог /scripts в PATH
ENV PATH="/scripts:${PATH}"

# Использовать правило iptables masquerade NAT
ENV IPTABLES_MASQ=1

# Следите за изменениями в файлах конфигурации интерфейса (по умолчанию отключено)
ENV WATCH_CHANGES=0

# Копирование файла из текущей папки в контейнер
COPY run.sh .

# Выставить права на каталог
RUN chmod 755 ./*

EXPOSE 5555/udp

# Запустить файл run.sh на исполнение, после запуска контейнера, внутри контейнера
ENTRYPOINT ["sh", "run.sh"]
