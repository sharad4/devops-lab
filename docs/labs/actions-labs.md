# GitHub Actions labs (A1–A8)

**A1 – YAML typo.** Use a tab in ci.yml. Find the error banner. Fix with `actionlint`.
**A2 – Lockfile drift.** Add a dependency in `package.json` without updating `package-lock.json`. See `npm ci` fail. Fix by committing the lockfile.
**A3 – Missing DB readiness.** Remove the MySQL `--health-*` options; run CI several times; observe flaky "connection refused". Restore.
**A4 – Wrong secret.** Rename `DEPLOY_HOST` secret; watch deploy fail at ssh. Learn to differentiate "empty secret" from "wrong value" (print `[ -n "$HOST" ] && echo set`).
**A5 – Permissions.** Remove `packages: write` in `cd.yml`; get `permission_denied: write_package`; fix.
**A6 – Cache bust.** Change the `key:` to something volatile (`${{ github.sha }}`) — see no cache hits; restore.
**A7 – Approval gate.** Run `cd.yml` via *Run workflow* with a tag; approve at `production` environment; reject once to see the failure path.
**A8 – Fail then recover.** Introduce a failing PHPUnit test, see `CI OK` red; use `gh run view --log-failed`, fix, re-run only failed jobs.

Stretch: add a reusable workflow (`workflow_call`), add a nightly cron smoke-test hitting staging `/api/health`, add path filters (`paths: ['frontend/**']`) and observe why the required check can stall (A2 pattern → that's what `ci-ok` is for).
