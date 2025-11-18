FROM python:3.13

# Директория приложения
WORKDIR /app

# Копирование списка зависимостей
COPY requirements.txt .

RUN pip install -r requirements.txt --no-cache-dir

# Копирование файлов сервиса
COPY . .

# Запуск сервиса
CMD ["python","manage.py","runserver","0:8000"]