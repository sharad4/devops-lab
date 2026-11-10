# Git: concepts and scenario cheat-sheet

## Mental model (memorise this)
Working tree → `git add` → **index/staging** → `git commit` → **local repo** → `git push` → **remote**.
A branch is just a movable pointer to a commit. `HEAD` is "where you are". Commits are immutable; "rewriting" creates *new* commits.
`git reflog` records everywhere HEAD has been, so almost nothing is truly lost for ~90 days.

## Daily flow
```bash
git switch -c feature/task-filter
git add -p                      # stage hunks deliberately
git commit -m "feat(api): filter tasks by done"
git fetch origin && git rebase origin/main   # update your branch (linear history)
git push -u origin feature/task-filter       # then open PR
```

## Scenario → command
| Scenario | Fix |
|---|---|
| Committed on the wrong branch (not pushed) | `git switch correct; git cherry-pick <sha>`; back on wrong: `git reset --hard HEAD~1` |
| Last commit message typo / forgot a file | `git add f; git commit --amend` (only if not pushed/shared) |
| Undo a commit **already pushed/shared** | `git revert <sha>` (new inverse commit; safe) |
| Undo local commits, keep changes | `git reset --soft HEAD~N` (staged) / `--mixed` (unstaged) |
| Threw away commits with `reset --hard` | `git reflog` → `git reset --hard <sha-before>` |
| Need to switch task mid-work | `git stash push -m wip -u` … `git stash pop` |
| Merge conflict | open files, fix `<<<<<<<` markers, `git add`, `git merge --continue` / `git rebase --continue`; abort with `--abort` |
| Same conflict again and again | `git config rerere.enabled true` |
| Find which commit broke things | `git bisect start; git bisect bad; git bisect good <sha>; git bisect run ./vendor/bin/phpunit` |
| Who changed this line & why | `git blame -L 10,30 file`; `git log -S"text" -p` |
| Pull one fix to release branch | `git cherry-pick -x <sha>` |
| Accidentally committed a **secret** | **Rotate the secret first.** Then `git filter-repo --path .env --invert-paths`, force-push, tell collaborators to re-clone. Deleting in a new commit does NOT remove it from history |
| Committed a huge file | `git filter-repo --strip-blobs-bigger-than 10M` (or move to Git LFS) |
| Detached HEAD, made commits | `git switch -c rescue` immediately |
| `push rejected (non-fast-forward)` | `git fetch; git rebase origin/<branch>` (or merge); never blindly `--force` |
| Force push needed after rebase | `git push --force-with-lease` (fails if someone else pushed) |
| Someone force-pushed over my work | `git reflog` on your clone; branch from your old sha; push to a new branch |
| Line-ending chaos (CRLF) | add `.gitattributes`: `* text=auto eol=lf` |
| Case-only rename ignored on macOS/Windows | `git mv -f File.php file.php` |
| Ignore rule added but file still tracked | `git rm --cached <file>` |
| Clean untracked files | `git clean -ndx` (dry run) then `-fdx` |
| Wrong author email | `git config user.email`; fix old: `git rebase -i --exec 'git commit --amend --reset-author --no-edit'` |
| Long-running branch diverged | `git merge-base main HEAD`; `git log --oneline --left-right main...HEAD` |
| Submodule / subtree confusion | avoid until needed |

## Merge vs rebase vs squash
- **Merge commit**: preserves true history; noisy.
- **Rebase**: linear history; rewrites *your* commits — never rebase shared branches.
- **Squash merge** (recommended default on GitHub): one commit per PR on `main`; easy to revert.

## Hooks (local guardrails)
`.git/hooks/pre-commit` (or use Husky/lefthook): run `./vendor/bin/pint --test` and `npm run lint`. Hooks are *advisory* (can be skipped with `--no-verify`) → CI is the real gate.
