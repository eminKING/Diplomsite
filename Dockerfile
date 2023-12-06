FROM nginx:latest

# Копирование конфигурации NGINX
COPY nginx.conf /etc/nginx/nginx.conf

# Копирование конфигурации upstream
COPY nginx_upstream.conf /etc/nginx/conf.d/nginx_upstream.conf

# Копирование конфигурации сервера
COPY server.conf /etc/nginx/conf.d/server.conf
