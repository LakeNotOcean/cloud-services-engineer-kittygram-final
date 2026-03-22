# Скрипт очистки системы
cat > /usr/local/bin/system_cleanup.sh << 'EOF'
#!/bin/bash

# Очистка устаревших пакетов
apt autoremove -y
apt clean

# Очистка логов старше 7 дней
find /var/log -type f -name "*.log" -mtime +7 -delete
find /var/log -type f -name "*.gz" -mtime +7 -delete

# Очистка временных файлов
rm -rf /tmp/*
rm -rf /var/tmp/*

# Очистка кэша журналов systemd
journalctl --vacuum-time=7d
EOF
chmod +x /usr/local/bin/system_cleanup.sh

# Добавление в cron для еженедельного выполнения
echo "0 0 * * 0 /usr/local/bin/system_cleanup.sh" >> /etc/crontab