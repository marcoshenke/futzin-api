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
    && docker-php-ext-enable opcache

# Instala e configura o Xdebug
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && apk add --update linux-headers \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del -f .build-deps

COPY .docker/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Instala o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia os arquivos do projeto
COPY . .

# Configura o diretório como seguro para o Git
RUN git config --global --add safe.directory /var/www/html

# Copia o arquivo .env de exemplo se não existir
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Instala as dependências do Composer
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Publica os assets do Sanctum
RUN php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

# Copia o arquivo de entrada personalizado
COPY docker/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Define as permissões
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expõe a porta 9000 e inicia o servidor PHP-FPM
EXPOSE 9000

# Ponto de entrada personalizado
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Comando padrão
CMD ["php-fpm"]
