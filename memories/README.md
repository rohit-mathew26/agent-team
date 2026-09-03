# Memories

Durable team memory. One fact per file. Written by the Manager, routed by
`scope` at spawn: global entries (`scope: all` or a repo id) reach every agent;
role-scoped entries (`scope: dev-engineer`, …) reach only that role's agents
plus the Manager, who always sees the full index.

```
_index.md          one line per memory — filtered by scope into agents' context
_compaction.md     compaction ledger — write counter and run log, Manager-only
feedback/          human feedback, distilled to its essence
rulings/           PM and Architect decisions that bind work beyond one task
failures/          stuck post-mortems: the dead ends worth never repeating
```

The protocol — what qualifies, how to distil it, how the loop closes — is in
[`../shared/memory-protocol.md`](../shared/memory-protocol.md). The file format
is enforced by [`../schemas/memory.schema.json`](../schemas/memory.schema.json).
Start from [`../templates/memory.md`](../templates/memory.md).

## Rules of the folder

1. **One fact per file.** A file with two rules gets half-applied.
2. **`_index.md` holds pointers, never content.** Every global line is loaded at
   every spawn, for every agent; role-scoped lines at every spawn of that role.
   Treat each line as expensive, and scope as narrowly as the rule allows.
3. **Only the Manager writes here.** Everyone else proposes via a `MEMORY`
   message.
4. **Supersede, don't overwrite.** Mark the old entry `superseded-by-<id>`. The
   history is what makes this auditable later.
5. **Prune aggressively.** An entry nobody has applied in a long while is either
   wrong or already absorbed into a role prompt. Both mean it should go.
6. **Compact every 5 writes.** The counter lives in `_compaction.md`; at the
   threshold the Manager summarizes each scope group before writing anything
   else. Merges preserve every rule at full strength; `pinned: true` entries
   pass through verbatim; prunes are explicit and logged. Procedure in
   `roles/manager.md`.

## Why this exists separately from the role prompts

Role prompts are the team's **design**: deliberate, reviewed, stable. Memories are
the team's **experience**: accumulated, situational, provisional.

Keeping them apart means feedback can be captured immediately without rewriting a
role prompt on every correction — and that a rule which proves itself repeatedly
can later be promoted into the prompt, while one that never fires can be dropped
without touching the design.
