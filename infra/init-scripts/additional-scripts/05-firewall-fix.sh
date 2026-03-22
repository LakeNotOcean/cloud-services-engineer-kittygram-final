# Настройка файрвола iptables с детальными правилами безопасности
mkdir -p /etc/iptables
# Очищаем все существующие правила и цепочки
iptables -F    # Удаляем все правила из всех цепочек
iptables -X    # Удаляем все пользовательские цепочки
iptables -Z    # Обнуляем все счётчики пакетов и байтов

# Устанавливаем базовые политики безопасности
iptables -P INPUT DROP      # Запрещаем весь входящий трафик по умолчанию
iptables -P FORWARD DROP    # Запрещаем перенаправление трафика
iptables -P OUTPUT ACCEPT   # Разрешаем исходящий трафик

# Разрешаем трафик на локальном интерфейсе (loopback)
# Это необходимо для корректной работы многих приложений
iptables -A INPUT -i lo -j ACCEPT    # Разрешаем входящий трафик на loopback
iptables -A OUTPUT -o lo -j ACCEPT   # Разрешаем исходящий трафик на loopback

# Разрешаем трафик для уже установленных соединений
# Это позволяет поддерживать существующие соединения
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Настраиваем защиту SSH от брутфорс-атак
# Создаём правило для отслеживания новых SSH-соединений
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set

# Блокируем IP-адреса, с которых идёт больше 4 попыток подключения в минуту
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent \
         --update --seconds 60 --hitcount 4 -j DROP

# Разрешаем SSH-подключения, прошедшие проверку на частоту
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Сохранение правил
iptables-save > /etc/iptables/rules.v4