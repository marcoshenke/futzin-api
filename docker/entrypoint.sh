#!/bin/sh

# Apenas executa se o arquivo .env existir
if [ -f .env ]; then
    # Gera a chave da aplicação se não existir
    if [ -z "$(grep -E '^APP_KEY=' .env)" ] || [ "$(grep -E '^APP_KEY=' .env | cut -d= -f2)" = "" ]; then
        php artisan key:generate
    fi

    # Limpa os caches
    php artisan config:clear
    php artisan cache:clear
    php artisan route:clear
    php artisan view:clear
fi

# Executa o comando principal (php-fpm)
exec "$@"
