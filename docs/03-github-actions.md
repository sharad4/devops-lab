# GitHub Actions: how it works and how to debug it

## Concepts
Event (`on:`) → **workflow** (YAML in `.github/workflows`) → **jobs** (parallel by default, each on a fresh runner VM) → **steps** (sequential; `run:` shell or `uses:` action).
Jobs share nothing unless you use **artifacts**, **cache**, or **outputs**. `needs:` creates ordering. `if:` gates. `matrix:` fans out. `concurrency:` serialises/cancels. `environment:` enables approvals and scoped secrets. `permissions:` sets GITHUB_TOKEN scope (default to least).

## What each workflow here teaches
| File | Teaches |
|---|---|
| `ci.yml` | service containers (MySQL + health check), caching, matrix, artifacts, concurrency, aggregate "CI OK" job for branch protection |
| `cd.yml` | GHCR login with `GITHUB_TOKEN`, buildx + GHA cache, job `outputs`, environments + approval, manual `workflow_dispatch` input, SSH deploy |
| `security.yml` | CodeQL, dependency-review, `composer/npm audit`, gitleaks, scheduled cron |
| `release.yml` | tag-triggered release, versioned images |

## Debug toolkit
1. Read the **first** red step, not the last. Expand the log; look 20 lines above the error.
2. Re-run with **"Enable debug logging"** (sets `ACTIONS_STEP_DEBUG`).
3. Add `- run: env | sort`, `pwd; ls -la`, `echo '${{ toJSON(github) }}'` (never print secrets; they're masked but derived values are not).
4. Reproduce locally: same container/commands. Try [`act`](https://github.com/nektos/act) for quick feedback (not 100% identical).
5. Validate YAML: `actionlint` (install and run locally: it catches expression, typo and shell errors).
6. Pin actions to a major (`@v4`) or SHA for supply-chain safety; Dependabot keeps them fresh.

## Failure catalogue
| Symptom | Cause → Fix |
|---|---|
| Workflow doesn't trigger | wrong branch in `on:`; file not in default branch (for `workflow_dispatch`/`schedule`); YAML syntax error (see Actions tab banner); commit message has `[skip ci]` |
| `Invalid workflow file` | tabs instead of spaces; bad `${{ }}`; run `actionlint` |
| `npm ci` → "package.json and package-lock.json are not in sync" | commit regenerated lockfile (`npm install` locally, same Node major) |
| `composer install` memory / "lock file out of date" | `composer update --lock`; commit `composer.lock` |
| MySQL "Connection refused" in tests | service not ready: add `--health-*` options (done), use `127.0.0.1` not `localhost`/`mysql` when job runs on the runner (not in a container) |
| Works locally, fails in CI | PHP/Node version drift, missing extension, case-sensitive filenames (Linux!), timezone, missing `.env`, tests depending on order |
| Cache never hits | key includes volatile data; wrong path; cache is scoped per branch (PRs read from base branch) |
| `Resource not accessible by integration` | add the needed `permissions:` (e.g. `packages: write`, `pull-requests: write`) |
| `secrets.X` is empty | secret defined in another environment/repo; fork PR; typo; org secret not shared to repo |
| Deploy job waits forever | environment *required reviewers* pending: approve in the run page |
| `ssh: Host key verification failed` | add `ssh-keyscan` (done) or pin host key as a secret |
| `Permission denied (publickey)` in deploy | key has CRLF/extra spaces (store with trailing newline), wrong user, public key not in `authorized_keys` |
| `docker: no space left on device` | `docker system prune`, reduce layers, or use larger runner |
| Required check "pending" forever | job skipped by `if:` → the aggregate **CI OK** pattern fixes this |
| Two deploys overlapped | missing `concurrency` group |
| Flaky test | rerun failed jobs; quarantine; fix root cause (time, randomness, shared DB state) |
| Action deprecation warning (Node 16/20) | bump the action major version |
| Rate limited pulling images | `docker/login-action` for Docker Hub or use GHCR mirrors |

## Security rules to internalise
- Never `echo` secrets; never `pull_request_target` + checkout of PR code with secrets.
- `permissions: contents: read` at the top, grant more per job.
- Treat `${{ github.event.pull_request.title }}` etc. as **untrusted input** (script injection) — pass through `env:` not directly into `run:`.
- Prefer OIDC to cloud providers over long-lived keys.
