# Workflow: Stuck Recovery

Terminate and respawn. The team does not coach a spun-out agent back to
productivity — recovering a polluted context costs more than starting clean, and
the recovery usually fails anyway.

```
Agent working
     |
     | PROGRESS every 10 tool calls
     v
[Manager] compares this PROGRESS to the last one
     |
     |  STATE changed?  ---yes---> continue
     |         |
     |         no
     v
STUCK DETERMINED  (or the agent sends SELF_STUCK first — the preferred path)
     |
     v
[Agent] SELF_STUCK: symptom, tried, RULED_OUT, suspect, needs, done
     |     (if the agent did not send one, the Manager reconstructs what it can
     |      from PROGRESS history — a much worse brief)
     v
[Manager] TERMINATE
     |
     v
[Manager] respawn decision:
     |
     +--> respawn_count < 2 ? --> spawn replacement with:
     |                              - the original task
     |                              - the respawn brief (RULED_OUT first)
     |                              - a NARROWER scope
     |                              - often a SMALLER budget
     |
     +--> respawn_count == 2 ? --> STOP. The task is the problem.
                                    Rescope it, or escalate to the human.
     v
[Manager] write the dead ends to memories/failures/ before context is discarded
```

## Stuck triggers

Any one fires. Full table in `shared/lifecycle.md`.

- No state change across two PROGRESS reports
- The same tool call three times
- The same command failing three times with no change in hypothesis
- Re-asking an already-answered question
- 80% of budget with no deliverable in sight
- Still blocked after the answer arrived
- Output drifting outside scope

## Why self-reporting is the cheap path

| Path | Cost |
|---|---|
| Agent sends `SELF_STUCK` early | One termination; replacement inherits `TRIED` and `RULED_OUT` and skips the dead ends |
| Manager detects it from PROGRESS | Termination plus the wasted cycles up to detection; brief is reconstructed and thinner |
| Nobody catches it until budget exhaustion | Full budget burned, no deliverable, replacement starts blind |

`RULED_OUT` is the highest-value field the team produces. It is the only mechanism
that stops the same wasted cycles from being paid for twice.

## The two-respawn rule

A task that defeats three agents is a bad task, not three bad agents. At that
point the Manager stops spawning and does one of:

- **Rescope** — split it smaller, or restate the criteria that were unclear.
- **Ask** — the ambiguity may be a PM or Architect question nobody named.
- **Escalate** — to the human operator, with the three briefs attached.

Spawning a fourth agent at the same scope is the most expensive mistake available
to the Manager.

## After recovery

Write to `memories/failures/`:

- What made it stuck — the trap, not the narrative.
- What ruled-out knowledge should survive the task.
- If the scoping was wrong, that is feedback about **task sizing**, and it belongs
  in memory as a rule for future decomposition.
