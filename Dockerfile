FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# Instala dependências do sistema
RUN apk add --no-cache \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libwebp-dev \
    libxml2-dev \
    oniguruma-dev \
    libmcrypt-dev \
    icu-dev \
    bash \
    mysql-client

# Configura extensões PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        opcache \
        zip \
        gd \
        intl \
        mbstring \
        exif \
        pcntl \
        bcmath \
        soap \
    && docker-php-ext-enable opcache

# Instala o Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copia os arquivos do projeto
COPY . .

# Configura o diretório como seguro para o Git
RUN git config --global --add safe.directory /var/www/html

# Copia o arquivo .env de exemplo se não existir
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Instala as dependências do Composer
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Configura as permissões
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Expõe a porta 9000 para o PHP-FPM
EXPOSE 9000

# Comando de inicialização personalizado
CMD ["sh", "-c", "php artisan key:generate && php artisan config:cache && php-fpm"]
