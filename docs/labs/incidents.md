# Incident drills: pick one per day, no peeking at solutions

For each: inject the fault, then diagnose *only from logs/metrics*, restore service, write a post-mortem (template in docs/05).

| # | Inject | What you should discover |
|---|---|---|
| 1 | On server, edit `.env` APP_KEY to empty; `docker compose up -d` | backend restart loop with "APP_KEY is not set" |
| 2 | Change `DB_PASSWORD` in server `.env` then redeploy | `Access denied`; MySQL volume retains old password |
| 3 | `chmod -R 000 storage` inside backend container | 500s; log write failure; fix ownership |
| 4 | Deploy a tag that doesn't exist (`./deploy.sh nope`) | `manifest unknown`; script leaves old version running |
| 5 | Deploy a build with a broken migration | health check fails → auto-rollback to previous tag; inspect `migrate:status` |
| 6 | Fill disk: `fallocate -l 90%` on server | docker pull fails; clean images/logs |
| 7 | Expire/rotate the GHCR PAT used on the server | `unauthorized` on pull; update `docker login` |
| 8 | Stop MySQL container | `/api/health` → 503 `db: down`; app stays up; alert/diagnose |
| 9 | Push a commit with `.env` secret | gitleaks + push protection; rotate + purge history |
| 10 | Break nginx upstream name (`backend` → `backend2`) in frontend conf and deploy | 502 Bad Gateway; compare `nginx -t`, container DNS |
| 11 | GitHub Actions outage simulation: disable Actions, ship hotfix via Jenkins | prove you have a second pipeline |
| 12 | Jenkins volume lost | rebuild from JCasC; restore backup |
