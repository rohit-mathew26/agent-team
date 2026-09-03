---
threshold: 5
writes_since_compaction: 0
last_compaction: none
runs: 0
---

# Compaction Ledger

Manager-only state; never loaded into any agent's prompt stack. Increment
`writes_since_compaction` as part of every memory write (create, supersede,
delete). When it reaches `threshold`, compact before the next write — procedure
in `roles/manager.md` § Compaction — then reset the counter to 0, set
`last_compaction`, bump `runs`, and append a run line below. Compaction's own
writes do not increment the counter.

## Runs

Newest last. One line per run:
`- YYYY-MM-DD — <scope>: <n> entries -> <m> (merged: ids; pruned: ids + reason); pins verified`

<!-- Entries below. -->
