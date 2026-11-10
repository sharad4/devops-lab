# syntax=docker/dockerfile:1
# Build context = repo root.  Requires backend/ to exist (run scripts/bootstrap-backend.sh).

FROM composer:2 AS vendor
WORKDIR /app
COPY backend/composer.json backend/composer.lock ./
# RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction
ENV COMPOSER_MAX_PARALLEL_HTTP=2 COMPOSER_PROCESS_TIMEOUT=900
RUN for i in 1 2 3 4 5; do \
      composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction && break \
      || { echo "retry $i"; sleep 3; }; \
    done \ 
    && test -d vendor
# COPY backend/ ./
# RUN composer dump-autoload --optimize --no-dev --no-scripts

COPY backend/ ./
RUN rm -f bootstrap/cache/*.php \
 && composer dump-autoload --optimize --no-dev --no-scripts

FROM php:8.4-fpm-alpine
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION} APP_ENV=production APP_DEBUG=false
RUN apk add --no-cache nginx supervisor curl \
 && docker-php-ext-install pdo_mysql opcache
WORKDIR /var/www/html
COPY --from=vendor /app ./
COPY docker/nginx-backend.conf /etc/nginx/http.d/default.conf
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
 && mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=3s --start-period=30s --retries=5 \
  CMD curl -fsS http://127.0.0.1:8080/api/health || exit 1
ENTRYPOINT ["/entrypoint.sh"]
