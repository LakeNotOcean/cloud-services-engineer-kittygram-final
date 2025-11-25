FROM python:3.14-alpine

# Дополнительные пакеты при необходимости
RUN apk add --no-cache \
    py3-setuptools 

# Директория сервиса
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

# Запуск сервиса (без применения миграции и сбора статистики)
CMD ["sh","-c","\
    python manage.py createsuperuser --noinput || true && \
    gunicorn -c gunicorn.conf.py kittygram_backend.wsgi:application"]