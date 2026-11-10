# Git labs (G1–G10)
Use a throwaway clone: `git clone <repo> git-lab && cd git-lab`. Try before reading the solution.

**G1 – Merge conflict.** Create `feature/a` and `feature/b` from main; both change line 1 of `frontend/src/App.jsx` `<h1>`. Merge a, then b.
Goal: resolve; `git merge --abort` once to practise. *Solution:* edit markers → `git add` → `git commit`. Enable `rerere`.

**G2 – Rebase conflict.** Rebase `feature/b` onto updated main, resolve across 2 commits. *Solution:* `git rebase main`, fix, `git add`, `git rebase --continue`.

**G3 – Lost work.** Make 3 commits, run `git reset --hard HEAD~3`. Recover. *Solution:* `git reflog` → `git reset --hard HEAD@{1}`.

**G4 – Revert a pushed bug.** Push a commit that breaks a test to a branch, then undo safely. *Solution:* `git revert <sha>` and push.

**G5 – Bisect.** Script: make 20 commits, one introduces `return 500` in HealthController. Find it. *Solution:* `git bisect start; git bisect bad; git bisect good <old>; git bisect run php artisan test --filter=health`.

**G6 – Interactive rebase.** Squash 5 messy "wip" commits into 2 clean ones; reword one. *Solution:* `git rebase -i HEAD~5` (`pick/squash/reword`).

**G7 – Cherry-pick hotfix.** Create `release/1.0`, fix a bug on main, port only that commit. *Solution:* `git switch release/1.0; git cherry-pick -x <sha>`.

**G8 – Secret leak.** Commit `.env` with a fake key and push to a *private test* repo. Remove it from history. *Solution:* rotate key (pretend), `git filter-repo --path .env --invert-paths`, `git push --force-with-lease --all`, then verify with `gitleaks detect`. Add `.env` to `.gitignore`, enable push protection.

**G9 – Force-push accident.** Two clones: A force-pushes a rebased branch while B has new commits. B recovers. *Solution:* in B `git fetch`, `git branch rescue <old-sha>` from reflog, `git rebase origin/branch` or cherry-pick rescue commits.

**G10 – Detached HEAD & stash.** `git checkout <sha>`, edit, commit; then switch away. Recover commit; also stash/pop a half-done change across branches. *Solution:* `git reflog` → `git branch rescue <sha>`.
