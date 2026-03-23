#!/bin/bash

# Создаём каталог для сохранения правил
mkdir -p /etc/iptables

# Удаляем правила
iptables -F INPUT
iptables -F FORWARD
iptables -F OUTPUT

# Обнуляем счётчики
iptables -Z

# Устанавливаем базовые политики безопасности
iptables -P INPUT DROP      # Запрещаем весь входящий трафик по умолчанию
iptables -P FORWARD ACCEPT  # Разрешаем перенаправление (нужно для Docker)
iptables -P OUTPUT ACCEPT   # Разрешаем исходящий трафик

# Разрешаем трафик на локальном интерфейсе
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Разрешаем трафик для уже установленных соединений
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Создаём правило для отслеживания новых SSH-соединений
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set

# Разрешаем SSH-подключения, прошедшие проверку на частоту
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Сохраняем правила
iptables-save > /etc/iptables/rules.v4