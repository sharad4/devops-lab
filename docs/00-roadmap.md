# Roadmap: 6 weeks to confident DevOps troubleshooting

Rule: **never skip the "break it" step.** You only learn to troubleshoot what you have personally broken.

| Week | Focus | Do | Done when you can… |
|---|---|---|---|
| 1 | **Git** | `01-git.md`, labs G1–G10 | recover from a bad reset, resolve any conflict, find a bug with bisect |
| 2 | **GitHub** | `02-github.md`, labs H1–H5 | enforce a PR-only workflow with required checks + CODEOWNERS |
| 3 | **GitHub Actions CI** | `03-github-actions.md`, labs A1–A8 | read a red run, reproduce locally, fix cache/service/secret issues |
| 4 | **Containers + CD** | provision a VM (`scripts/server-setup.sh`), run `cd.yml` to staging, then prod with approval | ship, health-check and roll back by hand and automatically |
| 5 | **Jenkins** | `04-jenkins.md`, labs J1–J10 | stand up Jenkins as code, multibranch + webhook, fix agent/credential/docker issues |
| 6 | **Incident drills** | `labs/incidents.md` (random-pick 1 per day, no hints) | diagnose using logs only, write a post-mortem |

## Environments you need
- **Laptop**: Docker, PHP, Composer, Node.
- **VM** (free tier / any $5 VPS / a local Ubuntu VM): used for staging; prod can be a second VM or a second compose project on a different port.
- **Public URL for Jenkins webhooks**: `ngrok http 8081` or a VM with a domain. Without it use *Poll SCM* (lab J6).

## Suggested branching (trunk-based, simple & realistic)
`main` is always deployable. Work on `feature/*`, `fix/*`, `hotfix/*`; open PR → CI green + 1 review → **squash merge** → auto-deploy to staging → manual promote to prod. Tag `vX.Y.Z` for releases.
Commit style: Conventional Commits (`feat:`, `fix:`, `chore:`, `ci:`, `docs:`).
