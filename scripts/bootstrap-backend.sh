#!/usr/bin/env bash
# Creates the Laravel app in ./backend and overlays our code. Run ONCE, then commit backend/.
set -euo pipefail
cd "$(dirname "$0")/.."

[ -d backend ] && { echo "backend/ already exists - aborting"; exit 1; }

composer create-project laravel/laravel:^12.0 backend --no-interaction
cd backend
php artisan install:api --no-interaction || true      # enables routes/api.php + Sanctum
composer require --dev laravel/pint --no-interaction  # code style (already present in new Laravel, harmless)
cd ..
cp -R backend-overlay/. backend/

# .env.example defaults for tests/CI: MySQL host comes from env, so leave as-is.
cd backend
php artisan key:generate
./vendor/bin/pint            # format so CI's 'pint --test' starts green
echo ">> Run: php artisan migrate && php artisan test"
echo ">> Then:  git add backend && git commit -m 'feat(backend): add Laravel task API'"
