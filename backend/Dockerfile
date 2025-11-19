FROM python:3.14-alpine

# Дополнительные пакеты при необходимости
RUN apk add --no-cache \
    py3-setuptools 

# Директория приложения
WORKDIR /app

# Копирование списка зависимостей
COPY requirements.txt .

# Устанавливаем зависимости от имени root
RUN pip install -r requirements.txt --no-cache-dir

# Копирование файлов сервиса
COPY . .

# Создание пользователя
RUN adduser -D -s /bin/sh -u 2000 appuser  && \
    mkdir -p /app/collected_static /app/media && \
    chown -R appuser:appuser /app

# Переключение на пользователя
USER appuser

# Запуск сервиса
CMD ["sh","-c","python manage.py collectstatic --noinput && python manage.py migrate && python manage.py createsuperuser --noinput || true && python manage.py runserver 0.0.0.0:8000"]