# Установка auditd
apt install auditd

# Настройка правил аудита
cat >> /etc/audit/rules.d/audit.rules << EOF
# Мониторинг изменений в системных файлах
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k sudo_actions

# Аудит системных вызовов
-a exit,always -F arch=b64 -S execve -k exec_commands
-a exit,always -F arch=b64 -S open -F dir=/etc -F success=0 -k access
-a exit,always -F arch=b64 -S open -F dir=/bin -F success=0 -k access
EOF

# Перезапуск службы аудита
service auditd restart