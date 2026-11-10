# Jenkins labs (J1–J10)

**J1 – First green build.** Multibranch job on your repo, main branch builds green.
**J2 – Missing plugin.** Remove `ssh-agent` from plugins.txt, rebuild; see `No such DSL method 'sshagent'`. Restore.
**J3 – Docker socket.** Remove the `docker.sock` mount; observe docker-agent failure. Restore. Then try running as non-root and fix with `--group-add`.
**J4 – Credential ID typo.** Change `ghcr-creds` to `ghcr-cred` in Jenkinsfile → `CredentialNotFoundException`. Fix.
**J5 – Secret leak.** Use double-quoted `sh "echo $P"` style interpolation and see the warning; fix by single quotes.
**J6 – Trigger methods.** (a) Poll SCM `H/2 * * * *`, (b) webhook via ngrok. Use GitHub *Recent Deliveries* to see response codes; break the URL (`/github-webhook` without slash) and fix.
**J7 – PR builds.** Open a PR; confirm a PR job appears and status posts to GitHub. Add Jenkins as required check.
**J8 – Approval timeout.** Let `input` expire (set 1 min) and see aborted build; add `post { aborted {} }`.
**J9 – Agent offline.** Add a second agent container (`jenkins/inbound-agent`), label `docker`, set `agent { label 'docker' }`; stop it and see "Waiting for next available executor".
**J10 – Disaster recovery.** `docker compose down -v` (destroys all state), then `up -d --build`. Jenkins must return fully configured from JCasC; re-add only multibranch job (then try Job DSL/JCasC jobs as stretch). Also practise backup: `docker run --rm -v jenkins_home:/v -v $PWD:/b alpine tar czf /b/jenkins_home.tgz -C /v .`
