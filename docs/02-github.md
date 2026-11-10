# GitHub: collaboration and governance

## 1. One-time repo settings (Settings →)
- **General → Pull Requests**: allow *squash merging* only; auto-delete head branches; allow auto-merge.
- **Rules → Rulesets** (or *Branches → protection*) for `main`:
  - Require a pull request, **1 approval**, dismiss stale approvals on new commits
  - Require review from **Code Owners** (see `.github/CODEOWNERS`)
  - Require status checks: **`CI OK`** (the aggregate job from `ci.yml`) + `Security / dependency-review`
  - Require branches be up to date; require linear history; **block force pushes & deletions**
  - (Solo? tick "Do not allow bypassing" only after you've finished setup, or add a second account to review.)
- **Code security**: enable Dependabot alerts + security updates, Secret scanning + **Push protection**, Code scanning (CodeQL from `security.yml`).
- **Environments**: create `staging` and `production`.
  - `production`: *Required reviewers* = you/team; *Deployment branches* = `main` only; *wait timer* optional.
  - Put deploy secrets **on the environment**, not repo-wide.
- **Secrets / variables**: `DEPLOY_SSH_KEY`, `DEPLOY_HOST`, `DEPLOY_USER` (secrets); `STAGING_URL`, `PRODUCTION_URL` (variables).
- **Packages**: after the first push to GHCR, set package visibility, and (Package settings → *Manage Actions access*) allow this repo to write.

## 2. Pull-request workflow
Issue → branch (`feature/12-filter`) → commits → **draft PR early** → CI green → review → *squash and merge* → branch auto-deleted.
Use `Closes #12` in the PR body to auto-close the issue. Use **auto-merge** to merge as soon as checks+approval pass.

## 3. Releases
`git tag -a v1.0.0 -m "First release" && git push origin v1.0.0` → `release.yml` publishes versioned images + auto release notes.

## 4. Auth options (and when each breaks)
| Method | Notes |
|---|---|
| SSH key | best for humans: `ssh -T git@github.com` to test |
| Fine-grained PAT | for Jenkins/scripts; expires → "Authentication failed" suddenly = expired token |
| `GITHUB_TOKEN` | per-run token in Actions; permissions controlled by `permissions:` block |
| Deploy key | read-only (or write) SSH key bound to ONE repo |
| GitHub App | best for org-grade automation |

## 5. Troubleshooting quick table
| Symptom | Likely cause / fix |
|---|---|
| `Permission denied (publickey)` | wrong key loaded: `ssh -vT git@github.com`, `ssh-add -l` |
| `remote: Support for password authentication was removed` | use PAT or SSH |
| `refusing to allow a PAT to create or update workflow` | PAT lacks `workflow` scope; or push from UI |
| Push to `main` rejected `protected branch` | expected: open a PR |
| Required check stays "Expected — Waiting" | workflow didn't run (path filters, wrong trigger, workflow file broken) or check **name** changed |
| PR from fork has no secrets | by design; use `pull_request_target` only with extreme care |
| Merge button blocked "Code owner review required" | CODEOWNERS username/team typo, or owner lacks write access |
| GHCR `denied: permission_denied: write_package` | workflow lacks `packages: write`, or repo not linked to package |
| `repository name must be lowercase` (GHCR) | use `${GITHUB_REPOSITORY_OWNER,,}` (already done in `cd.yml`) |
