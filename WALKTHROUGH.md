# Walkthrough

What this team supports, and how one task actually moves through it.
Companion to [README.md](README.md).

## Features

| # | Feature | Defined in |
|---|---|---|
| F1 | Six roles: 3 singletons with authority, 3 pooled for capacity | [team.yaml](team.yaml), [roles/](roles/) |
| F2 | Direct agent-to-agent messaging (mesh, no relay) | [shared/communication-protocol.md](shared/communication-protocol.md) |
| F3 | Manager visibility: cc on `RULING`/`BLOCKED`/`HANDOFF`/`SCOPE_CHANGE`/`CONFLICT` | same |
| F4 | Question routing by domain, search-first before asking | [shared/escalation.md](shared/escalation.md) |
| F5 | Conflict resolution — any party raises, only the Manager rules | same |
| F6 | Human escalation — Manager only, with defined triggers | same |
| F7 | Task decomposition to hard granularity limits (≤3 files, ≤5 criteria) | [roles/manager.md](roles/manager.md), [schemas/task.schema.json](schemas/task.schema.json) |
| F8 | Per-task budgets: tool calls, commands, wall-clock, messages | [shared/resource-discipline.md](shared/resource-discipline.md) |
| F9 | Warn at 70%, hard stop at 100%, specific extensions only | same |
| F10 | Tool-call economy: no call that changes no decision | same |
| F11 | Honest spend reporting, fed back into task sizing | same |
| F12 | `PROGRESS` reports every 10 tool calls | [shared/lifecycle.md](shared/lifecycle.md) |
| F13 | Stuck detection — 7 objective triggers | same |
| F14 | Terminate + respawn with a `RULED_OUT` brief; 2-respawn cap | [workflows/stuck-recovery.md](workflows/stuck-recovery.md) |
| F15 | No self-review, no self-verification | [team.yaml](team.yaml) constraints |
| F16 | Single-writer ownership, disjoint write sets for safe parallelism | same |
| F17 | Definition of Done gate; only the Manager sets `DONE` | [shared/definition-of-done.md](shared/definition-of-done.md) |
| F18 | `SCOPE_CHANGE` — discovered work is never absorbed silently | [shared/charter.md](shared/charter.md) |
| F19 | `BLOCKED` with a mandatory `COMPLETED` field | [shared/escalation.md](shared/escalation.md) |
| F20 | Schema-validated artifacts (task, review, test plan, memory) | [schemas/](schemas/) |
| F21 | Memory capture: human feedback distilled to its essence | [shared/memory-protocol.md](shared/memory-protocol.md) |
| F22 | Memory index injected at spawn; supersede and prune | [memories/](memories/) |
| F23 | Binding decisions recorded as ADRs / PRD amendments | [templates/](templates/) |
| F24 | Four workflows: feature, bug fix, spike, stuck recovery | [workflows/](workflows/) |
| F25 | PM-only descope; PM-only acceptance | [roles/product-manager.md](roles/product-manager.md) |
| F26 | Multi-repo deployment from a workspace manifest | [schemas/workspace.schema.json](schemas/workspace.schema.json), [templates/workspace.yaml](templates/workspace.yaml) |
| F27 | One task = one repo; repo-qualified write paths | [schemas/task.schema.json](schemas/task.schema.json) |
| F28 | Architect-owned cross-repo contracts + compatibility strategy | [roles/architect.md](roles/architect.md) |
| F29 | Producer-before-consumer sequencing, each stage shippable alone | [workflows/cross-repo-change.md](workflows/cross-repo-change.md) |
| F30 | Cold-repo orientation uplift, repaid as a repo brief | [templates/repo-brief.md](templates/repo-brief.md) |
| F31 | Cross-repo integration verification; read-only repos | [roles/qe-engineer.md](roles/qe-engineer.md) |
| F32 | Manager is the sole spawner; no other role may spawn | [shared/lifecycle.md](shared/lifecycle.md) |
| F33 | Singletons: exactly one instance, spawned once, kept for the whole goal | [team.yaml](team.yaml) |
| F34 | Pooled roles: many concurrent instances, one task each | same |

---

## A task, end to end

**Goal:** expired sessions currently dump users to a blank page.

### 1. PM writes the requirement — F25, F23

```
FROM: product-manager   TO: manager
TYPE: ANSWER
DECISION: Expired session routes to sign-in with a "Session expired" notice;
          any unsaved draft is preserved and restored after re-auth.
CRITERIA: AC-1 GIVEN a token expired >24h WHEN the dashboard opens
                THEN sign-in is shown with the notice
          AC-2 AND an unsaved draft is restored after sign-in
BINDING:  yes  -> PRD amended, MEMORY proposed
```

### 2. Architect defines the seam — F1, F23

Asked by the Manager before any fan-out, so the two tasks can own different
files.

```
DECISION: Draft persistence goes behind DraftStore (auth/draft-store.ts:
          save/restore/clear). The auth redirect path depends on the
          interface, not on storage.
BOUNDARY: Covers draft survival across re-auth. Does not cover cross-device.
ADR:      ADR-014
```

### 3. Manager decomposes — F7, F16, F8

Two tasks, **disjoint write sets**, each inside the default budget:

| Task | Write paths | Criteria | Budget |
|---|---|---|---|
| `EXP-101` redirect + notice | `auth/guard.ts`, `auth/messages.ts` | AC-1 | 40/10/20m/8 |
| `EXP-102` draft persistence | `auth/draft-store.ts` | AC-2 | 40/10/20m/8 |

A single task touching four files would have been split — the limit is three.

### 4. Devs work in parallel — F12, F2, F4

`dev#1` and `dev#2` spawn, one task each. At call 10:

```
FROM: dev-engineer#1   TO: manager
TYPE: PROGRESS
STATE: guard.ts redirect path implemented; notice copy pending
NEXT:  wire messages.ts
SPEND: 11/40 calls, 1 command, 4m
```

`dev#1` hits an ambiguity and asks the **owner directly** — no relay:

```
FROM: dev-engineer#1   TO: product-manager        (Manager NOT cc'd)
TYPE: QUESTION
Q:    Does the notice show for a token expired <24h, or only >24h?
TRIED: PRD §3, ADR-014, memories/_index.md — none cover the shorter window
OPTIONS: (a) notice for any expiry (b) only >24h per AC-1 literally
RECOMMEND: (a) — a user cannot tell the two apart
```

PM answers in one message. Total cost: two messages, zero Manager context.

### 5. A budget warning — F9, F11

```
FROM: dev-engineer#2   TO: manager
TYPE: BUDGET
CONSUMED: 28/40 calls, 7/10 commands, 14m
REMAINING WORK: restore-after-signin path, untested
ASSESS: will not finish; the restore path needs its own integration test
```

Manager grants **a specific amount with a reason** — `+15 calls, +5 commands, to
finish the restore path` — and records that `EXP-102` was under-sized.

### 6. Review — F15, F20, F3

A reviewer that is **not** the author:

```
FROM: code-reviewer#1   TO: dev-engineer#1   CC: manager
TYPE: REPORT
VERDICT: BLOCK
FINDINGS:
 - SEVERITY: blocking
   LOCATION: auth/guard.ts:64
   CLAIM:    Draft is cleared before the redirect, so AC-2 cannot hold.
   SCENARIO: user with an unsaved draft + expired token -> clear() runs at :64
             -> restore() finds nothing -> draft lost
   FIX:      clear only after a successful restore
SPEND: 14/40 calls, 0 commands, 6m
```

Goes **straight to the author**, Manager cc'd. The author fixes it and hands off
again; the same reviewer re-checks.

### 7. QE — F15, F20

A QE agent that is not the author attacks the author's stated `RISKS` first:

```
RESULT: PASS
CRITERIA:    AC-1 -> case B-3 pass; AC-2 -> case S-2 pass
EXECUTED:    happy-path 2, boundary 3, state 2, permission 1
NOT_COVERED: concurrency — two tabs expiring at once. Single-tab only in scope.
CONFIDENCE:  a second tab restoring the same draft is where I'd expect trouble
SPEND: 22/40 calls, 6 commands, 11m
```

### 8. Done — F17, F21

Manager checks every clause of the Definition of Done, sets `DONE`, retires
`dev#1`, `dev#2`, the reviewer and the QE agent, and writes the memory before
their context is discarded.

---

## Use cases exercising the rest

### A. A dev finds unrelated broken code — F18

```
TYPE: SCOPE_CHANGE   TO: product-manager   CC: manager
FOUND: auth/session.ts:88 swallows refresh errors. Pre-existing, not in AC-1/2.
COST:  ~1 task
```
Dev does **not** fix it and keeps going. PM returns a verdict: new task, defer,
or reject. Nothing is absorbed silently.

### B. An agent spins — F13, F14

`dev#3` runs the same failing migration command a third time with no changed
hypothesis. Trigger fires; it self-reports first:

```
TYPE: SELF_STUCK
SYMPTOM:   migration fails on the test fixture, passes locally
TRIED:     schema drift (no), ordering (no), fixture seed (no)
RULED_OUT: schema drift, migration ordering — do not re-attempt
SUSPECT:   the fixture is generated from a stale dump
DONE:      up-migration written and reviewed
```

Manager terminates, respawns with **narrower scope** and a smaller budget. The
replacement reads `RULED_OUT` first and skips three dead ends. `respawn_count: 1`.

### C. Two respawns exhausted — F6, F14

The replacement also fails. `respawn_count` hits 2, so the Manager **stops
spawning** — a task that defeats three agents is a bad task — and escalates:

```
TYPE: ESCALATION
TRIGGER:   second_respawn_exhausted
SITUATION: fixture generation is outside every agent's write scope
OPTIONS:   (a) grant fixture write access (b) regenerate fixtures out-of-band
RECOMMEND: (b) — smaller blast radius
COST_SO_FAR: 96 calls, 41m across 3 agents
```

### D. PM and Architect deadlock — F5

PM requires realtime sync; Architect rules the store cannot serve it within
budget. Neither concedes. Either raises a `CONFLICT`; the **Manager rules** on the
cost/delivery axis, names which axis it used, propagates the `RULING`, and records
it in `memories/rulings/`. Not re-litigated without new evidence.

### E. A reviewer disagrees with a criterion — F5

Not a review finding. The reviewer raises a `CONFLICT` to the Manager rather than
blocking a merge over a product decision.

### F. Blocked, but not idle — F19

```
TYPE: BLOCKED   TO: architect   CC: manager
BLOCKER:   Should retry live in the gateway or the client?
COMPLETED: error surface, tests for the non-retry path, messages.ts
```
`COMPLETED` is mandatory — being blocked on one branch never justifies idling on
the others while wall-clock burns.

### G. Feasibility unknown — F24 (spike)

Manager issues a **time-boxed** spike: the question, the decision it unblocks, the
box. Dev prototypes throwaway code, stops at the box, reports `ANSWER` +
`CONFIDENCE` + `UNKNOWNS`. Prototype is discarded; the Manager writes a fresh
tight task from the Architect's ruling. A spike never becomes the implementation.

### H. A human corrects the team — F21, F22

> "Stop running the whole suite on every edit — run the file's tests until the
> end."

Manager distils to the **rule and its reason**, not the transcript:

```
mem-0004 (feedback, scope: dev-engineer, qe-engineer)
Run only the affected test file during work; run the full suite once before
handoff.
Why: full-suite runs on each edit burn the command budget and change no decision.
```

Index line added; every agent spawned afterward loads it. If a later rule
supersedes it, the old entry is marked `superseded-by` rather than edited — that
history is what makes the loop auditable.

### I. A bug arrives — F24 (bug fix), F10

QE reproduces **first** and writes a failing test; no fix without a reproduction,
and reproduction is itself capped — if QE cannot reproduce inside budget, "not
reproducible, here is what was tried" is a valid result and the PM decides whether
to spend more. The Dev then states the **root cause**, not just the patch.

### J. One goal, three repos — F26, F27, F28, F29, F30, F31

`POST /v2/session` must return `expiresAt`, and the web client must use it.
Workspace: `api` (producer), `web` (consumer, cold), `docs` (read-only).

**Architect rules the contract first** — `CT-1`, `expand-contract`, `ADR-014`.
Without it, both repos invent an incompatible shape.

**Stage 1, expand.** One dev in `api` adds `expiresAt` *alongside* the existing
field. Write paths `api:src/session.ts`, `api:src/schema.ts`. Reviewed, verified,
`DONE`, shippable on its own.

**Stage 2, migrate.** Only now is the `web` task assigned — the gate is the
producer being `DONE`, not in review. `web` is cold, so the task carries `+15`
tool calls and the dev returns a repo brief with it; the next agent into `web`
pays nothing. The dev notices `docs` is stale and does **not** touch it —
`write_allowed: false` makes that a `SCOPE_CHANGE`, not an edit.

**Stage 3, contract.** A separate task removes the old field — and only after
`web` is not merely merged but *deployed*. Folding this into stage 1 would have
recreated the atomic-merge problem that expand-contract exists to avoid.

**Stage 4, integration.** One QE agent gets the only task allowed to span repos:
reads `api` and `web`, writes contract tests in `api`, checks both skew directions
(old consumer against new producer, and the reverse). Defects are reported per
repo, against a specific criterion.

### K. An agent wants help — F32, F33, F34

A Dev deep in a task sees that the fixture generator also needs fixing, and that
a second agent could do it in parallel. It **cannot spawn one**. It sends a
`SCOPE_CHANGE` and keeps going; the Manager decides whether that becomes a task.

The rule holds because only the Manager sees the whole workspace — it is the only
role that can guarantee two agents never hold the same write path, that a reviewer
is never the author, and that pool caps and budgets mean anything. A self-spawned
helper breaks all three silently.

The same rule governs the singletons from the other direction. When a second Dev
needs a product answer, the Manager does **not** spawn a second Product Manager —
it addresses the one that has been alive since the goal started. A second PM is a
second source of product truth, which is the exact thing having one PM prevents.
Pooled roles are the opposite: eight Devs at once is normal, each on its own task,
each retired when it lands.

---

## Coverage

| Feature | Exercised in |
|---|---|
| F1, F7, F16, F17, F20 | Main walkthrough, steps 2–8 |
| F2, F4 | Step 4 |
| F3 | Steps 4, 6 (cc rules) |
| F5 | Use cases D, E |
| F6 | Use case C |
| F8, F9, F11 | Steps 3, 5 |
| F10 | Use case I |
| F12 | Step 4 |
| F13, F14 | Use cases B, C |
| F15 | Steps 6, 7 |
| F18 | Use case A |
| F19 | Use case F |
| F21, F22 | Step 8, use case H |
| F23, F25 | Steps 1, 2 |
| F24 | Use cases G, I |
| F26–F31 | Use case J |
| F32–F34 | Use case K |
