FROM php:8.4-fpm-alpine3.22

ENV ACCEPT_EULA=Y

# Set working directory
WORKDIR /var/www/laravel

# Install base dependencies
RUN apk --no-cache add --update \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    libxpm-dev \
    freetype-dev \
    libzip-dev \
    oniguruma-dev \
    zip \
    su-exec \
    unzip \
    bash \
    gnupg \
    fcgi \
    nginx \
    supervisor \
    libxml2-dev \
    openssl \
    libpq-dev \
    postgresql-dev \
    autoconf

# Install MSSQL drivers
RUN curl -O https://download.microsoft.com/download/7/6/d/76de322a-d860-4894-9945-f0cc5d6a45f8/msodbcsql18_18.4.1.1-1_amd64.apk \
    && curl -O https://download.microsoft.com/download/7/6/d/76de322a-d860-4894-9945-f0cc5d6a45f8/mssql-tools18_18.4.1.1-1_amd64.apk \
    && curl -O https://download.microsoft.com/download/7/6/d/76de322a-d860-4894-9945-f0cc5d6a45f8/msodbcsql18_18.4.1.1-1_amd64.sig \
    && curl -O https://download.microsoft.com/download/7/6/d/76de322a-d860-4894-9945-f0cc5d6a45f8/mssql-tools18_18.4.1.1-1_amd64.sig \
    && curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --import - \
    && gpg --verify msodbcsql18_18.4.1.1-1_amd64.sig msodbcsql18_18.4.1.1-1_amd64.apk \
    && gpg --verify mssql-tools18_18.4.1.1-1_amd64.sig mssql-tools18_18.4.1.1-1_amd64.apk \
    && apk add --allow-untrusted msodbcsql18_18.4.1.1-1_amd64.apk mssql-tools18_18.4.1.1-1_amd64.apk \
    && rm -f *.apk *.sig

# Install PHP extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/install-php-extensions
RUN chmod uga+x /usr/bin/install-php-extensions \
    && sync \
    && install-php-extensions pdo pcntl gd bcmath mbstring pdo_pgsql ds exif intl opcache pdo_sqlsrv redis sqlsrv zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy application files
COPY . /var/www/laravel

# Copy configuration files
COPY conf.d/nginx/default.conf /etc/nginx/nginx.conf
COPY conf.d/nginx/50x.html /usr/share/nginx/html/50x.html
COPY conf.d/php/php.ini /usr/local/etc/php/conf.d/php.ini
COPY conf.d/supervisor/supervisord.conf /etc/supervisord.conf
COPY conf.d/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY conf.d/php-fpm/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf


# Set proper permissions
RUN chown -R www-data:www-data /var/www/laravel \
    && chmod -R 775 /var/www/laravel/storage /var/www/laravel/bootstrap/cache

# Scheduler setup
RUN touch /var/log/cron.log
RUN echo "* * * * * /usr/local/bin/php /var/www/laravel/artisan schedule:run >> /var/log/cron.log 2>&1" | crontab -

# Clean up
RUN apk del gnupg autoconf \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

EXPOSE 80
ADD entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
