# Memories

Durable team memory. One fact per file. Written by the Manager, read by everyone
at spawn.

```
_index.md          one line per memory — loaded into every agent's context
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
2. **`_index.md` holds pointers, never content.** It is loaded in full, every
   spawn, for every agent. Treat each line as expensive.
3. **Only the Manager writes here.** Everyone else proposes via a `MEMORY`
   message.
4. **Supersede, don't overwrite.** Mark the old entry `superseded-by-<id>`. The
   history is what makes this auditable later.
5. **Prune aggressively.** An entry nobody has applied in a long while is either
   wrong or already absorbed into a role prompt. Both mean it should go.

## Why this exists separately from the role prompts

Role prompts are the team's **design**: deliberate, reviewed, stable. Memories are
the team's **experience**: accumulated, situational, provisional.

Keeping them apart means feedback can be captured immediately without rewriting a
role prompt on every correction — and that a rule which proves itself repeatedly
can later be promoted into the prompt, while one that never fires can be dropped
without touching the design.
