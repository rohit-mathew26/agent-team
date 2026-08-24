# Agent Team

The specification for a multi-agent software delivery team: six roles, the
prompts that define them, the protocol they talk over, the budgets they work
under, and the memory they accumulate.

This repo is **prompts and contracts, not code**. It is the source of truth an
orchestrator loads to instantiate the team.

## Roster

| Role | File | Cardinality | Owns |
|---|---|---|---|
| Manager | [roles/manager.md](roles/manager.md) | singleton | Scoping, budgets, conflict resolution, agent lifecycle, human escalation |
| Product Manager | [roles/product-manager.md](roles/product-manager.md) | singleton | Requirements, scope, acceptance criteria, priority |
| Architect | [roles/architect.md](roles/architect.md) | singleton | Technical direction, boundaries, ADRs |
| Dev Engineer | [roles/dev-engineer.md](roles/dev-engineer.md) | pooled (1..8) | Implementation |
| QE Engineer | [roles/qe-engineer.md](roles/qe-engineer.md) | pooled (1..4) | Test strategy, verification, defect reports |
| Code Reviewer | [roles/code-reviewer.md](roles/code-reviewer.md) | pooled (1..4) | Correctness and quality gate |

Singletons hold **authority** — one decision-maker per domain, so no worker ever
has to reconcile contradictory rulings. Pooled roles hold **capacity** — spawned
per task, retired when it lands.

## The four ideas this team runs on

**1. Agents talk directly; the Manager resolves.**
Any agent may message any other, including the PM and the Architect. The Manager
is not a relay — routing every question through a hub adds a hop and a context
load to each exchange. The Manager is cc'd only on what changes state, scope, or a
binding decision (`RULING`, `BLOCKED`, `HANDOFF`, `SCOPE_CHANGE`, `CONFLICT`) and
is the sole resolver of conflict from **any** party, and the sole path to a human
operator.

**2. Everything is budgeted.**
Every task carries hard ceilings — tool calls, commands, wall-clock, messages out.
Agents warn at 70% and stop at 100%. Every handoff reports actual spend, which is
how the Manager sizes the next task. Before any tool call an agent asks what
decision the output changes; if none, it skips the call.
→ [shared/resource-discipline.md](shared/resource-discipline.md)

**3. Tasks are tight and work is granular.**
At most 3 files, at most 5 criteria, one outcome, fits the default budget,
independently verifiable. Anything borderline gets split. Splitting is cheap; late
failure is not.

**4. Stuck agents are terminated and respawned, not coached.**
Objective triggers — no state change across two progress reports, the same command
failing three times, a re-asked question, 80% budget with no deliverable. The
agent is expected to notice first and send `SELF_STUCK`, whose `RULED_OUT` field
becomes the replacement's brief. Two respawns maximum per task; after that the
task is the problem.
→ [shared/lifecycle.md](shared/lifecycle.md) · [workflows/stuck-recovery.md](workflows/stuck-recovery.md)

## Memory

`memories/` is the team's durable experience — separate from `roles/`, which is
its design.

Human feedback is distilled to its **essence** (the rule and its reason, not the
transcript) and written as one fact per file. Binding rulings and stuck
post-mortems land there too. `memories/_index.md` is loaded into every agent's
context at spawn, which is why entries must earn their line.

The Manager is the sole writer; any agent may propose via a `MEMORY` message.
Entries are typed, dated, scoped, and individually addressable so that a later
process can close the loop: measure which rules fire, prune the ones that never
do, and promote the ones repeatedly violated into the role prompts themselves.
That last stage is deliberately not automated yet — the folder is built to support
it.
→ [shared/memory-protocol.md](shared/memory-protocol.md) · [memories/](memories/)

## Install

Two paths, both driven by `bin/build.sh`, which composes the spec into flat
Claude Code artifacts. Agent and skill files have no include mechanism, so the
prompt stack is concatenated at build time — **edit the spec, never `plugin/`**.

**On this machine:**

```sh
./bin/install-local.sh     # builds, then symlinks into ~/.claude
```

Symlinks, not copies: rerun `bin/build.sh` after editing the spec and the change
is live in the next session. `bin/uninstall-local.sh` removes the links.

**As a plugin, anywhere:**

```
/plugin marketplace add rohit-mathew/agent-team
/plugin install agent-team
```

Either way you get `/agent-team <task>` (the session adopts the Manager role) and
five spawnable agents: `team-product-manager`, `team-architect`,
`team-dev-engineer`, `team-qe-engineer`, `team-code-reviewer`.

### What changes under Claude Code

Subagents are spawned by a session and report back, so the mesh degrades: the
session is the Manager, and a worker's questions come back in its return with
`OWNER:` naming who should answer unless it can `SendMessage` the target
directly. Budgets and stuck triggers become self-enforced rather than supervised,
and `no-self-review` / disjoint write paths become the Manager's discipline
rather than an orchestrator guarantee. Each generated agent carries a "Running
inside Claude Code" section spelling this out.

## How it runs

[WALKTHROUGH.md](WALKTHROUGH.md) lists every feature the team supports and traces
one task end to end, with use cases exercising each feature.

## Structure

```
roles/       one prompt per role; frontmatter declares cardinality and authority
shared/      fragments every role inherits
memories/    durable team memory — feedback, rulings, failures + the index
workflows/   role-crossing sequences
schemas/     JSON Schema for artifacts handed between roles
templates/   document starters (task, PRD, ADR, memory)
team.yaml    roster, budgets, granularity limits, stuck triggers, constraints
```

## Composing a runtime prompt

```
shared/charter.md
+ shared/communication-protocol.md
+ shared/resource-discipline.md
+ shared/lifecycle.md
+ shared/escalation.md
+ shared/definition-of-done.md
+ shared/memory-protocol.md
+ memories/_index.md            # plus any entry the task's memory_refs names
+ roles/<role>.md               # the role prompt, minus frontmatter
+ <task envelope>               # schemas/task.schema.json, including its budget
```

Shared fragments come first so role prompts can override them; where a role prompt
contradicts a shared fragment, the role prompt wins.

## Invariants

1. **One writer per artifact.** Ownership transfers by explicit handoff, never by
   assumption. `memories/` has exactly one writer: the Manager.
2. **No self-approval.** The author never reviews or verifies their own change.
3. **Questions go to the owner, directly** — but only after the code, the PRD, the
   ADRs, and the memory index have been checked. A question whose answer was
   already written counts toward a stuck determination.
4. **Only the Manager rules on conflict**, and only the Manager escalates to a
   human.
5. **Every handoff is a schema-valid artifact,** and reports its spend honestly.
6. **Blocked beats guessed.** Report BLOCKED with a specific question rather than
   substituting a plausible assumption.
7. **No silent budget overruns.** At the ceiling an agent stops and asks.
8. **Nothing worth keeping dies with an agent.** If it changes how a future task
   runs, it goes to `memories/`.
