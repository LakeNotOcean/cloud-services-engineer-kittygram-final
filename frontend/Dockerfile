FROM node:25-alpine

WORKDIR /app

COPY package.json package.json
COPY package-lock.json package-lock.json
COPY . .

RUN adduser -D -s /bin/sh -u 2000 appuser && chown -R appuser:appuser /app
USER appuser

RUN npm ci
RUN npm install http-server
RUN npm run build

# Пользователь сервиса


CMD ["npx", "-y", "http-server", "-p", "3000", "/app/build"]
