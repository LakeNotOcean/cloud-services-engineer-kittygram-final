FROM node:25-alpine

# Директория сервиса
WORKDIR /app

# Копирование файлов сервиса
COPY package.json package.json
COPY package-lock.json package-lock.json
COPY . .

# Создание пользователя
RUN adduser -D -s /bin/sh -u 2000 appuser && chown -R appuser:appuser /app

# Переключение на пользователя
USER appuser

# Установка зависимостей
RUN npm ci
RUN npm install http-server
RUN npm run build

# Запуск сервиса
CMD ["npx", "-y", "http-server", "-p", "3000", "/app/build"]
