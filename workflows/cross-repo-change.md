# Workflow: Cross-Repo Change

One goal, several repos. The hard constraint: **there is no atomic merge across
repos.** Every cross-repo change is therefore a sequence of independently
shippable single-repo changes, ordered so the tree is never broken between them.

## The rule that makes it work

**One task = one repo.** An agent is deployed into exactly one repo, works only
there, and reports back. Cross-repo work is a *chain* of single-repo tasks bound
by a contract — never one agent roaming across checkouts.

Why: an agent working in two repos must hold two sets of conventions, two build
systems, and two test commands in one context, and its write set can no longer be
checked for collision against other agents. The single exception is the
integration verification task in step 6, which reads everywhere and writes in one
place.

## Sequence

```
[Manager] read workspace.yaml — repos, roles, dependencies, per-repo commands
     |
     v
[Architect] define the CONTRACT and its compatibility strategy      -> ADR
     |        expand-contract (default) | versioned | breaking-coordinated
     v
[Manager] order the chain by depends_on: producer first, consumers after
     |
     v
--- STAGE 1: EXPAND (producer repo) ----------------------------------------
[Dev in api] add the NEW surface alongside the old one. Nothing breaks.
[Reviewer in api] + [QE in api] -> lands and ships independently
     |
     v
--- STAGE 2: MIGRATE (consumer repos, now parallel) -------------------------
[Dev in web]     [Dev in mobile]      one agent per repo, disjoint by construction
     |                |
     +--- both build against the new surface, which already exists
     v
[Reviewer + QE per repo] -> each lands independently
     |
     v
--- STAGE 3: CONTRACT (producer repo) --------------------------------------
[Dev in api] remove the old surface, now that no consumer uses it
     |
     v
--- STAGE 4: INTEGRATION ----------------------------------------------------
[QE] contract verification across repos: read every repo, write tests in one
     |
     v
[Manager] DONE only when every repo in the chain is done
```

Stage 3 is a separate task, usually a separate day. A Manager who folds it into
stage 1 has recreated the atomic-merge problem.

## Manager rules for multi-repo work

| Rule | Why |
|---|---|
| One repo per task, always | Context, conventions, and collision-checking are all per-repo |
| Write paths are repo-qualified — `api:src/auth.ts` | Single-writer must hold *across* the workspace, not within one repo |
| Producer before consumer, without exception | A consumer built against a surface that does not exist yet cannot be verified |
| Every repo in the chain ships green on its own | If stage 2 stalls, stage 1 must still be releasable |
| Cold repos get a budget uplift | Orientation is real work; see below |
| Never assign a consumer task before the producer's task is `DONE` | Not "in review" — `DONE` |
| A stuck agent respawns **into the same repo** | Its `RULED_OUT` is repo-specific and does not transfer |

## Budget in a multi-repo workspace

Orientation is the new cost, and it is per repo, not per task.

- **Cold repo uplift.** The first task in a repo the team has not worked in gets
  `+15 tool calls` for orientation. Subsequent tasks there do not — by then the
  repo brief and the memories exist.
- **The repo brief is how the uplift is repaid.** The first agent into a repo is
  expected to return brief material worth committing (`templates/repo-brief.md`).
  The second agent reads it instead of rediscovering.
- **Never pay orientation twice for the same repo in one goal.** Prefer giving a
  second task in `api` to a fresh agent *with the brief* over letting one agent
  hold two repos to "save" the ramp — the second option costs more and breaks the
  one-repo rule.
- **Commands come from the workspace**, never from discovery. An agent running
  `ls` to find the test command is a workspace file the Manager failed to fill in.

## Verification across repos

Per-repo QE verifies its own repo's criteria. That is not enough for the goal:
each repo can pass alone while the contract between them is wrong.

The integration task (stage 4) is the one task allowed to span repos:

- **Reads** every repo in the chain.
- **Writes** tests in exactly one — normally the producer, or a dedicated
  contract-test location named in the workspace.
- **Verifies the contract surface**, not the internals: the shape the producer
  emits is the shape consumers parse, in both directions, including the error and
  version-skew cases.
- **Runs against the real versions that will be deployed together**, not against
  a branch that exists only locally.

## When a repo is read-only

`write_allowed: false` means agents may read it for context and never modify it.
Anything needed there becomes a `SCOPE_CHANGE` to the Manager, who takes it up
with whoever owns that repo. An agent that edits a read-only repo has violated
the workspace, not just its task.

## Rollback

Because the stages ship separately, rollback is per-stage and asymmetric:

- **Stage 1 (expand)** is additive — safe to leave in place even if the goal is
  abandoned. Prefer leaving it over reverting.
- **Stage 2 (migrate)** reverts per consumer repo, independently.
- **Stage 3 (contract)** is the only irreversible step, because it deletes the old
  surface. Do not run it until every consumer is confirmed `DONE` **and shipped**
  — a consumer that is merged but not deployed still needs the old surface.
