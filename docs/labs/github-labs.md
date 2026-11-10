# GitHub labs (H1–H5)

**H1 – Branch protection.** Enable the `main` ruleset (docs/02). Try `git push origin main` directly. Expected: rejected. Open PR instead; confirm merge is blocked until `CI OK` passes + approval.

**H2 – Required check that never reports.** Rename job `ci-ok` → `ci-done` in ci.yml. Observe PR stuck at "Expected". Fix by updating either the workflow or the required check name. Lesson: required checks match by *name*.

**H3 – CODEOWNERS.** Put a wrong username in CODEOWNERS → "code owner review required" can't be satisfied. Fix; then add a path rule for `/docker/`.

**H4 – Dependabot PR.** Let Dependabot open a PR (or trigger from Insights → Dependency graph). Review, confirm CI runs on it, merge with auto-merge.

**H5 – Secret push protection.** Try committing a fake AWS key `AKIAIOSFODNN7EXAMPLE` pattern in a test branch. See push blocked or flagged; practise the bypass-with-reason flow vs. fixing properly.
