# DevOps Lab: Laravel + React with Git, GitHub, GitHub Actions & Jenkins

A small but production-shaped app (Task manager: **Laravel 12 API + React/Vite SPA + MySQL**) wrapped in a
complete delivery pipeline. The app is intentionally simple; the **pipeline, workflow and failure scenarios** are the point.

```
 developer ──git──► GitHub (PR, review, branch protection)
                      │
        ┌─────────────┴──────────────┐
        ▼                            ▼
 GitHub Actions                   Jenkins (Multibranch)
 CI: lint+test+build              same CI, independent runner
 CD: push to GHCR → staging       build/push → staging → approval → prod
 manual dispatch → prod (approval)
        │                            │
        └────────────► GHCR images ◄─┘
                           │  ssh + docker compose (scripts/deploy.sh, auto-rollback)
                           ▼
                 Staging / Production VM
              [nginx+React] → [nginx+php-fpm Laravel] → [MySQL]
```

## Repo map
| Path | Purpose |
|---|---|
| `backend-overlay/` | Our Laravel code. `scripts/bootstrap-backend.sh` creates `backend/` and copies this over it |
| `frontend/` | React + Vite + Vitest + ESLint |
| `docker/` | Production Dockerfiles, nginx, supervisor, entrypoint |
| `docker-compose.yml` / `docker-compose.prod.yml` | Local stack / server stack |
| `.github/workflows/` | `ci.yml`, `cd.yml`, `security.yml`, `release.yml` |
| `.github/` | CODEOWNERS, PR template, Dependabot |
| `Jenkinsfile`, `jenkins/` | Pipeline + Jenkins-in-Docker with Configuration-as-Code |
| `scripts/` | bootstrap, server-setup, deploy (health-check + auto-rollback), rollback |
| `docs/` | Roadmap, per-tool guides, troubleshooting playbook, break-and-fix labs |

## Quick start (30 min)
Prereqs: Git, Docker, PHP 8.3 + Composer, Node 20, a GitHub account.

```bash
# 1. Generate the Laravel app and the lockfiles (CI uses `composer install` / `npm ci`, which need lockfiles)
./scripts/bootstrap-backend.sh
(cd backend && php artisan migrate && php artisan test)
(cd frontend && npm install && npm test && npm run build)

# 2. Run the full stack locally
cp .env.example .env
php -r "echo 'APP_KEY=base64:'.base64_encode(random_bytes(32)).PHP_EOL;"   # paste into .env
docker compose up --build        # open http://localhost:8080

# 3. Put it on GitHub  (do this on main, then follow docs/02-github.md for protection rules)
git init -b main && git add . && git commit -m "chore: initial project"
git remote add origin git@github.com:<you>/devops-lab.git && git push -u origin main
```
Then follow **`docs/00-roadmap.md`** — a week-by-week path through every tool, ending in the labs.

> **Honest note:** this scaffold was authored without network access, so the Laravel skeleton, `composer.lock`,
> `package-lock.json` and first pipeline runs have *not* been executed by the author. Expect to fix 1–3 small things
> on first run (versions, code style, secrets). That is deliberate practice — `docs/05-troubleshooting.md` tells you how.
