# Memory Protocol

The team keeps a durable memory in `memories/`. It exists so the same correction
never has to be given twice — by a human or by anyone else.

Agents are disposable; memories are not. When a pooled agent is retired, its
context is gone. Anything that should change how a **future** task is run must be
written to memories, or it is lost.

## What goes in

| Type | Trigger | Folder |
|---|---|---|
| `feedback` | A human corrected, redirected, or confirmed an approach | `memories/feedback/` |
| `ruling` | A PM or Architect decision that binds work beyond its own task | `memories/rulings/` |
| `failure` | A stuck/respawn post-mortem — the dead ends worth never repeating | `memories/failures/` |

## What stays out

- Anything the repo already records: code structure, the PRD, an ADR that exists,
  git history.
- Task-local detail — that belongs in the handoff.
- Praise, restatements of the charter, or an entry that only says what a role
  prompt already says.
- Anything you inferred rather than observed.

If a memory does not change what a future agent would **do**, it is noise. The
index is loaded into agents' context at spawn; every line costs every agent in
its scope.

## Distil to the essence

Human feedback arrives as conversation. What gets written is the durable core,
not the transcript. Strip the occasion, keep the rule.

> **Raw:** "No — don't run the whole suite every time you touch a file, that's
> burning minutes on every task, just run the file's own tests until the end."
>
> **Essence:** Run only the affected test file during work; run the full suite
> once, before handoff.

The test: could an agent who never saw the original exchange act on this
correctly? If not, it is under-distilled. Is it longer than the rule requires? It
is over-recorded.

## Global vs role-specific memory

Every memory carries a `scope` that decides who loads it:

- **Global** (`scope: all`, or a repo id / path): in every agent's index. Use for
  rules any role could violate — tone of external artifacts, git hygiene,
  workspace conventions.
- **Role-specific** (`scope: <role>`, e.g. `scope: dev-engineer`): loaded only
  into that role's agents, plus the Manager, who as sole writer always sees the
  full index. Use for rules only one role can act on — how a reviewer phrases
  findings, what a QE agent must re-run, what a dev must include in a handoff.

Default to the narrowest scope that covers everyone who could violate the rule.
A dev-only rule scoped `all` costs the PM, the Architect, and every reviewer
context for something they can never apply; a cross-role rule scoped to one role
silently exempts everyone else. When feedback names a role's behaviour, scope it
to the role; when it names an artifact any role produces, scope it `all`.

Valid role scopes: `manager`, `product-manager`, `architect`, `dev-engineer`,
`qe-engineer`, `code-reviewer`.

## Scope memories to a repo

In a multi-repo workspace, most of what is worth remembering is true of **one
repo**, not all of them: a flaky suite, a generated file that looks editable, a
build step with a trap in it.

Set `scope` to the repo id (`scope: api`) so it reaches only agents deployed
there. A repo-specific rule written as `scope: all` costs every other agent
context for something that will never apply to them, and invites being applied
where it is wrong.

Repo-specific knowledge that is stable belongs in that repo's brief
(`templates/repo-brief.md`) rather than in memory. Use memory for what the brief
missed — and when the same thing is missed twice, fix the brief.

## Format

One fact per file, `memories/<type>/<slug>.md`, valid against
`schemas/memory.schema.json`:

```markdown
---
id: mem-0007
type: feedback | ruling | failure
scope: all | <role> | <path or component>
source: human | product-manager | architect | manager | <role>#<instance>
date: YYYY-MM-DD
status: active | superseded-by-<id>
---

<The rule, stated as an instruction a future agent can follow.>

**Why:** <the reason — a rule without its reason gets misapplied at the edges>
**Applies when:** <the trigger condition>
**Related:** [[mem-0003]]
```

## Writing and reading

- **The Manager is the sole writer.** Single writer, as with any artifact. Any
  agent may propose one:

  ```
  TYPE: MEMORY
  TO:      manager
  PROPOSE: <the distilled rule>
  WHY:     <what it would have changed>
  EVIDENCE:<what happened that prompted it>
  ```

- **Every agent gets its slice of the index at spawn.** Global entries reach
  everyone; role-scoped entries reach only their role (the Manager sees all).
  Read the full entry when an index line touches your task.
- **Check before writing.** If an entry already covers it, update that entry
  rather than adding a near-duplicate. Two entries saying almost the same thing
  is worse than one.
- **Supersede, never silently edit.** A rule that changes gets a new entry; the
  old one is marked `superseded-by`. The history is what makes the loop
  auditable.
- **Delete what turns out to be wrong.** A stale memory is worse than no memory:
  agents follow it.

## Compaction

Memory grows one write at a time and is read at every spawn, so it is compacted
on a cadence: after every 5 writes — counted in `memories/_compaction.md` — the
Manager summarizes each scope group (global, then each role's), merging entries
that are facets of one rule, pruning dead weight, and tightening index lines.
The procedure and its cadence tracking are the Manager's duty; the full
procedure is in the Manager role prompt.

Two guarantees hold across rounds, so repeated compaction cannot erode memory:

- **No rule loses force.** A merged entry carries every constituent instruction
  at full strength — trigger, reason, and exact prohibition. A merge that would
  generalize or soften any source is not made. Entries leave memory only by
  explicit prune with a logged reason, never as a side effect of summarizing.
- **`pinned: true` is untouchable.** An entry pinned by the Manager — because a
  human stated it emphatically, or its exact wording matters — passes through
  every round verbatim: not merged, not reworded, not pruned.

Any agent may flag a rule as pin-worthy in a `MEMORY` proposal; only the Manager
sets the field.

## The loop

```
   human feedback ──┐
   binding ruling ──┼──> [Manager distils] ──> memories/<type>/<slug>.md
   stuck post-mortem┘                                    │
                                                         v
                                              memories/_index.md
                                                         │
                            ┌────────────────────────────┘
                            v
              routed by scope at spawn: global entries to every
              agent, role-scoped entries to that role only
                            │
                            v
                    agents apply the rule
                            │
                            v
        outcomes + spend recorded in handoffs and retros
                            │
                            v
        every 5 writes: compaction — merge facets, prune dead
        weight, carry pinned entries verbatim
                            │
                            v
        [future] rules that keep being violated get promoted
                 into the role prompts themselves
```

Compaction closes the pruning half of the loop on a fixed cadence. Promotion
into role prompts is still manual; entries stay typed, dated, scoped, and
individually addressable so a later process can measure which ones are doing
work and which are dead weight.
