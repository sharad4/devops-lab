# Jenkins: setup, pipeline concepts, and debugging

## Start it (Jenkins as code)
```bash
cd jenkins && cp .env.example .env     # set admin password, GHCR PAT, URL
docker compose -f docker-compose.jenkins.yml up -d --build
# open http://localhost:8081  (admin / your password)
docker compose -f docker-compose.jenkins.yml logs -f jenkins
```
`casc.yaml` (Configuration-as-Code) creates the admin user, URL, and credentials **from environment variables** so Jenkins is reproducible — destroy the volume and it comes back identical (lab J10).

## Concepts
- **Controller** schedules; **agents/executors** run builds. Here controller runs builds itself (lab only; real world: separate agents, 0 executors on controller).
- **Declarative Pipeline** (`pipeline { agent stages steps post }`) vs scripted (Groovy). We use declarative + `script {}` where needed.
- **Multibranch Pipeline**: scans the GitHub repo, creates a job per branch/PR from the `Jenkinsfile`.
- **Credentials**: IDs referenced in the Jenkinsfile → `ghcr-creds`, `deploy-ssh`, `deploy-ssh-prod`, `deploy-host`, `deploy-host-prod`, `deploy-user`.
- **Workspace** is per-job-per-node and persists; `cleanWs()` in `post.cleanup` avoids stale-file bugs.
- **Docker agents**: `agent { docker { image 'node:20-alpine' } }` runs steps inside a container; `reuseNode true` shares the workspace.
- **`input`** step = manual approval gate (never hold an executor: `agent none` for approval in big setups).

## Wire up the project
1. **Credentials** → add the 6 IDs above (SSH private keys via *SSH Username with private key*; host/user as *Secret text*).
2. **Manage Jenkins → System → Global properties** → env var `GHCR_OWNER=<your-github-username>`.
3. **New Item → Multibranch Pipeline** → Branch Source: GitHub → credentials `github-pat` → repo → Build Configuration: by Jenkinsfile.
4. **Trigger**: GitHub repo → Settings → Webhooks → `https://<public-url>/github-webhook/` (content type `application/json`, events: push + PRs). No public URL? Use *Scan Multibranch Pipeline Triggers* (periodic, e.g. 2 min).
5. **Report back to GitHub**: Branch Source → *Behaviours* → keep defaults (status checks via GitHub Branch Source). Add Jenkins' check name as a **required status check** in branch protection if you want Jenkins to gate merges.

## GitHub Actions vs Jenkins (know both)
| Aspect | GitHub Actions | Jenkins |
|---|---|---|
| Hosting | managed runners | you run it (patching, backups, plugins) |
| Config | YAML in repo | Jenkinsfile (Groovy) + controller config |
| Ecosystem | marketplace actions | ~1800 plugins |
| Secrets | repo/env secrets | credentials store |
| Best for | GitHub-native, quick start | complex/legacy, on-prem, custom agents, heavy builds |

## Debug toolkit
- **Console Output** first red line. Use *Replay* to test Jenkinsfile edits without committing.
- **Pipeline Syntax** snippet generator (bottom of job config page).
- `sh 'set -x; env | sort'` and `sh 'id; pwd; ls -la; docker ps'`.
- **Manage Jenkins → System Log** and `docker logs jenkins`.
- Script Console (Manage Jenkins) for Groovy introspection (admin only!).
- `docker exec -it jenkins bash` and run the failing command by hand, as the same user.

## Failure catalogue
| Symptom | Cause → Fix |
|---|---|
| `docker: command not found` | CLI missing in image (we install `docker-ce-cli`) |
| `permission denied ... /var/run/docker.sock` | user not in docker group / socket not mounted; lab runs as root, or `--group-add $(stat -c %g /var/run/docker.sock)` |
| Docker agent: `Cannot connect to the Docker daemon` | socket mount missing; DinD not running |
| Docker-agent files owned by root break next build | `args '-u root'` + `cleanWs()` or run with matching uid |
| Webhook delivers 403/404 | URL must end `/github-webhook/`; CSRF/crumb or auth proxy; check GitHub → Webhooks → *Recent Deliveries* |
| Webhook 200 but no build | job isn't multibranch/GitHub-trigger enabled; branch filtered; run *Scan Repository Now* |
| `Authentication failed` / `Could not resolve host` on checkout | PAT expired/scopes (`repo`, `admin:repo_hook`); DNS in container; proxy |
| `No such DSL method 'sshagent'` / `Plugin missing` | install plugin (add to `plugins.txt`, rebuild) |
| `groovy.lang.MissingPropertyException` | undefined variable; env vars need `env.` in Groovy, `$VAR` in `sh` |
| Secrets showing in logs | use `withCredentials` + single-quoted `sh '...'` (Groovy interpolation leaks) |
| `WorkflowScript: ... expected a symbol` | syntax error; use Pipeline Linter or *Replay* |
| Stuck "Waiting for next available executor" | no free executors/offline agent; raise executors; check Nodes |
| Disk full | `buildDiscarder`, prune Docker (`docker system prune -af` on agent), clean workspaces |
| Builds slow | cache `~/.composer`, `~/.npm` via a mounted volume; parallel stages (already used) |
| `input` step never completes | no `submitter` match / timeout; check "Paused for Input" in stage view |
| `Scripts not permitted to use method ...` | Script Security sandbox → approve in *In-process Script Approval* only if reviewed |
| Jenkins won't boot after plugin update | read `docker logs`; roll back plugin by restoring volume backup; pin versions in `plugins.txt` |

## Operate Jenkins like production
Backup `jenkins_home` volume; pin plugin versions; restrict anonymous; no builds on controller; run behind HTTPS reverse proxy; upgrade LTS monthly; keep secrets only in credentials store.
