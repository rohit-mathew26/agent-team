---
id: mem-0006
type: feedback
scope: all
source: human
date: 2026-08-25
status: active
---

Determine whether a branch is published with `git ls-remote --heads origin <branch>`,
never from `git branch -r`, `git status -sb`, or any `origin/*` tracking ref. Pin
force-pushes with `--force-with-lease=<branch>:<sha>` using the SHA just observed.

**Why:** Remote-tracking refs are a local cache refreshed only on fetch. A branch
was reported to the human as unpushed on that basis while it already existed on the
remote, understating the consequence of a later force-push.

**Applies when:** Reporting push/publish state to a human, or before any push,
force-push, or history rewrite.
