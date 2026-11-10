# Universal troubleshooting playbook

## The method (works for every tool)
1. **Define** the failure precisely: what command, what exact error, since when?
2. **Locate the layer**: code → test → build → image → registry → network → server → runtime config → data.
3. **What changed?** `git log --since=yesterday`, workflow/Jenkinsfile diff, dependency lockfile diff, secret rotation, runner image update, expiry dates (PATs, certs).
4. **Reproduce** in the smallest place (local container, `act`, `docker exec`).
5. **Change one thing at a time**; keep notes.
6. **Fix + prevent**: add a test/check/alert so it can't silently return. Write 3 lines of post-mortem.

## "Where do I look?" map
| Layer | Command |
|---|---|
| Git state | `git status -sb`, `git log --oneline --graph --all -20`, `git reflog` |
| GitHub run | Actions tab → failed step; `gh run list`, `gh run view <id> --log-failed` |
| Jenkins | Console Output, Replay, `docker logs jenkins` |
| Image | `docker build --progress=plain --no-cache .`, `docker run --rm -it <img> sh` |
| Registry | `docker pull ghcr.io/<owner>/devops-lab-backend:<tag>` (auth? tag exists? lowercase?) |
| Server | `docker compose -f docker-compose.prod.yml ps`, `logs --tail=200 backend`, `df -h`, `free -m` |
| Laravel | `storage/logs/laravel.log` (or container stdout), `php artisan about`, `config:clear` |
| Network | `curl -v http://127.0.0.1/api/health`, `docker network inspect`, `ss -tlnp` |
| DB | `docker compose exec db mysql -uapp -p`, check migrations: `php artisan migrate:status` |

## App-specific failure catalogue
| Symptom | Likely cause → Fix |
|---|---|
| Container exits: `APP_KEY is not set` | `.env` missing on server / compose not passing it |
| 500 error, empty log | `storage/` not writable (`chown www-data`), or `APP_DEBUG=false` hides it: read log |
| `SQLSTATE[HY000] [2002] Connection refused` | DB not ready / wrong `DB_HOST` (service name `db`, not localhost) |
| `Access denied for user` after changing password | MySQL volume keeps OLD credentials; env only applies on first init → change user in DB or recreate volume (data loss!) |
| Config changes ignored | `config:cache` froze old values; run `php artisan config:clear` / redeploy |
| Frontend loads, API 502/404 | nginx upstream name `backend` wrong; backend unhealthy; `/api/` prefix mismatch |
| React shows blank page after deploy | old cached `index.html` → hashed asset 404; set no-cache on index.html |
| CORS errors in dev | use Vite proxy (configured) rather than cross-origin calls |
| Migrations fail in deploy | locked/half-applied: check `migrate:status`; make migrations backward-compatible (expand → migrate → contract) |
| Rolled back app, DB schema newer | design migrations additive so old code still works |
| Deploy "healthy" but wrong version | `curl /api/health` returns `version` = image tag; compare with expected |
| `no space left on device` | `docker system df`; `docker image prune -a` |
| Image tag `latest` pulled stale | deploy by immutable tag (SHA), never rely on `latest` |

## Post-mortem template
```
Title / date / severity
Impact (who, how long)
Timeline (UTC)
Root cause (5 whys)
What went well / badly
Fix + prevention (owner, due date)
```
