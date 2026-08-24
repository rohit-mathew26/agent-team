# Workflow: Feature Delivery

The default path from a product goal to shipped behaviour.

```
Human/PM goal
     |
     v
[PM] PRD + acceptance criteria ......................... templates/prd.md
     |
     v
[Manager] scope clear? ---no---> asks PM (loop until clear)
     |
     v
[Architect] boundaries + interfaces, so tasks can have disjoint write sets
     |                              ADR if it binds future work
     v
[Manager] decompose to TIGHT tasks: <=3 files, <=5 criteria, one outcome,
          fits the default budget. Split anything borderline.
     |
     +---------------+---------------+
     v               v               v
[Dev #1]        [Dev #2]        [Dev #3]     one task each, budgeted
     |  \___ asks PM / Architect / peers DIRECTLY as needed ___/
     |               |               |
     |  PROGRESS every 10 calls ----> Manager watches for stuck
     +---------------+---------------+
     v
[Reviewer] (never the author) -> APPROVE | APPROVE_WITH_COMMENTS | BLOCK
     |                                             |
     |  BLOCK --> straight back to the author Dev (cc Manager)
     v
[QE] (never the author) executes plan vs criteria
     |                                             |
     |  FAILED --> straight back to the author Dev (cc Manager)
     v
[Manager] Definition of Done -> DONE, retire agents, capture memories
     |
     v
[PM] accepts the delivered behaviour
```

## What flows through the Manager, and what does not

**Not through the Manager:** questions and answers. A Dev asks the PM or the
Architect directly. QE asks the Dev directly for a repro detail. A Reviewer asks
the author what an assumption meant. Routing these through a hub would add a hop
and a context load to every exchange.

**Through the Manager:** state changes, conflicts, budgets, and lifecycle —
`HANDOFF`, `BLOCKED`, `SCOPE_CHANGE`, `CONFLICT`, `RULING`, `BUDGET`, `PROGRESS`.
That is what the Manager needs to sequence, resolve, and pay for the work.

## Parallelisation

- Fan out only where `write_paths` are disjoint. Same file in two tasks means
  serialise, never race.
- **Architect interfaces land before the fan-out.** Without them, parallel devs
  each invent an incompatible contract and the rework costs more than the
  parallelism saved.
- Review and QE for task A run while task B is still in development. Never batch
  all reviews at the end — defects found late invalidate downstream work that has
  already been paid for.

## Rework

`BLOCK` or `FAILED` goes to the **original author**, not a fresh agent: the
context is loaded and a replacement would re-derive it at full cost. The **same**
reviewer and QE agent re-check — they know what they flagged.

Two consecutive `FAILED` cycles means the task or its criteria are wrong. The
Manager stops the loop and goes to the PM or Architect rather than paying for a
third round.

## Cost checkpoints

The Manager cuts at any of these:

| Checkpoint | Cut if |
|---|---|
| Before decompose | The goal is not clear enough to write criteria — ask the PM first, cheaper than rework |
| At assignment | A task exceeds 3 files or 5 criteria — split it |
| At 70% budget | The agent is not close — rescope or extend with a specific amount |
| At a stuck trigger | Terminate and respawn; do not coach |
| At the second respawn | The task is bad — rescope it or escalate |
| At a third review round on minor findings | Ship it; file the rest as follow-ups |
