#!/bin/sh

# --- CONFIGURATION ---
BASEDIR="/var/www/laravel"
SUPERVISOR_CONF="/etc/supervisord.conf"
SUPERVISOR_BIN="/usr/bin/supervisord"

cd "$BASEDIR" || { echo "Directory $BASEDIR not found!"; exit 1; }

# --- FUNCTIONS ---

is_fresh_install() {
    [ ! -f ".env" ]
}

generate_env_file() {
    if [ "$PRODUCTION" = "1" ]; then
        ENV_FILE=".env.production"
    else
        ENV_FILE=".env.example"
    fi

    echo "Generating .env from $ENV_FILE ..."
    cp "$ENV_FILE" .env
    echo ".env file generated."
}

composer_install() {
    if [ "$PRODUCTION" = "1" ]; then
        composer install --no-dev --no-interaction --no-scripts --ignore-platform-req=ext-pcntl
    else
        composer install --no-interaction --no-scripts --ignore-platform-req=ext-pcntl
    fi
}

artisan_cmd() {
    php artisan "$@"
}

# --- MAIN SCRIPT ---

if is_fresh_install; then
    echo "This is a FRESH INSTALL."
    generate_env_file
fi

echo "Clearing compiled classes..."
artisan_cmd clear-compiled

echo "Installing composer dependencies..."
composer_install

echo "Generating app key..."
artisan_cmd key:generate --force

echo "Clearing optimization cache..."
artisan_cmd optimize:clear

echo "Removing old storage link..."
rm -rf public/storage

echo "Creating new storage link..."
artisan_cmd storage:link

echo "Running database migrations..."
artisan_cmd migrate --force

if [ "$PRODUCTION" = "1" ]; then
    echo "Running in production mode"
else
    echo "Running in development mode"
fi

echo "Starting supervisord..."
exec "$SUPERVISOR_BIN" -c "$SUPERVISOR_CONF"
