FROM nginx:alpine

# Директория сервиса
WORKDIR /app

# Копирование файлов сервиса
COPY nginx.conf /etc/nginx/templates/default.conf.template

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]