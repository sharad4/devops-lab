#!/bin/sh
set -e
cd /var/www/html
[ -z "$APP_KEY" ] && { echo "FATAL: APP_KEY is not set"; exit 1; }

php artisan config:cache
php artisan route:cache
if [ "${RUN_MIGRATIONS:-false}" = "true" ]; then
  php artisan migrate --force
fi
exec /usr/bin/supervisord -c /etc/supervisord.conf
