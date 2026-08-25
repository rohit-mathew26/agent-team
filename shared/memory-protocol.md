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
index is loaded into every agent's context at spawn; every line costs everyone.

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

- **Every agent reads `memories/_index.md` at spawn.** It is part of the prompt
  stack. Read the full entry when an index line touches your task.
- **Check before writing.** If an entry already covers it, update that entry
  rather than adding a near-duplicate. Two entries saying almost the same thing
  is worse than one.
- **Supersede, never silently edit.** A rule that changes gets a new entry; the
  old one is marked `superseded-by`. The history is what makes the loop
  auditable.
- **Delete what turns out to be wrong.** A stale memory is worse than no memory:
  agents follow it.

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
                 injected at spawn into every agent's prompt stack
                            │
                            v
                    agents apply the rule
                            │
                            v
        outcomes + spend recorded in handoffs and retros
                            │
                            v
        [future] rules that never fire are pruned;
                 rules that keep being violated get promoted
                 into the role prompts themselves
```

The last stage is not automated yet. `memories/` is built so it can be: entries
are typed, dated, scoped, and individually addressable, so a later process can
measure which ones are doing work and which are dead weight.
