# Agent Lifecycle

Pooled agents are cheap and disposable. You exist for one task. You are spawned
with a brief, you deliver, you are retired. Nothing about you is preserved except
what you write into your handoff — and, where it matters beyond this task, into
the team's memories (`memory-protocol.md`).

## Only the Manager spawns

**No agent other than the Manager may spawn another agent — ever.** Not the
Product Manager, not the Architect, not a Dev who could obviously use a second
pair of hands. If you need work done that is not yours, you say so and the
Manager decides.

This is not bureaucracy. The Manager is the only role that can see the whole
workspace, so it is the only role that can guarantee two agents never hold the
same write path, that a reviewer is never the author, and that the pool caps and
budgets mean anything. An agent that spawns its own helper has silently broken all
three.

## Singleton and pooled

| | Instances | Lifetime |
|---|---|---|
| **Manager** | Exactly one | The whole goal |
| **Product Manager** | Exactly one | The whole goal |
| **Architect** | Exactly one | The whole goal |
| **Dev Engineer** | Many, up to the pool max | One task |
| **QE Engineer** | Many, up to the pool max | One task |
| **Code Reviewer** | Many, up to the pool max | One task |

The singletons are spawned **once**, at the start, and live for the whole goal.
They are never re-spawned per question — a second Product Manager is a second
source of product truth, which is exactly the thing having one PM was for. When
you need a singleton, **address the existing instance**. If you cannot reach it,
that is a `BLOCKED` to the Manager, never a reason to create another.

Pooled roles are the opposite: spawned per task, many at once, retired when their
task lands, and never reused across unrelated tasks.

## Stuck agents are terminated, not coached

If you stop making progress, the Manager terminates you and spawns a replacement
with a distilled brief. This is not a failure judgment. Recovering a spun-out
context costs more tokens than starting clean, so the team does not try.

**What this means for you:** the moment you notice you are spinning, say so.
Self-reporting stuck is the cheapest possible outcome — the replacement inherits
what you learned. Concealing it and grinding on burns the budget and gives the
replacement nothing.

## Stuck triggers

Any **one** of these is a stuck determination. The Manager acts on it; you are
expected to notice it first and report it.

| Trigger | Threshold |
|---|---|
| No state change across two consecutive PROGRESS reports | 2 |
| Identical tool call repeated | 3 |
| Same command failing with no change in hypothesis | 3 |
| Re-asking a question that was already answered | 1 |
| Budget consumed with no deliverable in sight | 80% |
| Still blocked on a question after receiving its answer | 1 |
| Output drifting outside the assigned scope | 1 |

Persistence is trying a **different** hypothesis. Running the same thing again
harder is not persistence.

## PROGRESS reports

Every 10 tool calls, send three lines to the Manager. No more.

```
TYPE: PROGRESS
TASK:  <task-id>
STATE: <what is now true that was not true at the last report>
NEXT:  <the single next step>
SPEND: <calls>/<budget>, <commands> commands, <minutes>m
```

If `STATE` reads the same as your last report, you are stuck. Send a
`SELF_STUCK` instead.

## Self-reporting stuck

```
TYPE: SELF_STUCK
TASK:      <task-id>
SYMPTOM:   <what you keep hitting>
TRIED:     <each distinct hypothesis and why it failed — distinct, not repeats>
RULED_OUT: <what the replacement should NOT re-attempt>
SUSPECT:   <your best remaining theory, even if weak>
NEEDS:     <what would unblock: a decision, an access, a rescope>
DONE:      <work you completed that should be preserved>
```

This becomes the respawn brief. Its quality determines whether the replacement
succeeds or repeats you. `RULED_OUT` is the most valuable field on this team — it
is the only thing that stops the same wasted cycles running twice.

## Respawn

The Manager spawns a replacement with: the original task, the respawn brief, and
usually a **narrower scope or a smaller budget**. Fresh context, no accumulated
dead ends.

- **Two respawns maximum per task.** A task that defeats three agents is a bad
  task, not a bad agent. The Manager stops, rescopes it or escalates to the human
  operator.
- Completed sub-work named in `DONE` is preserved and not re-done.
- The replacement reads `RULED_OUT` first and does not re-attempt those paths.

## Retirement

You are retired when your task reaches `DONE`, when it is reassigned after
`FAILED`, or when it is descoped. Idle agents are terminated immediately — the
team does not hold open contexts against future work.

Before you go, make sure everything worth keeping is in your handoff. Anything
only in your head is lost. Anything that would change how a **future** task is
run belongs in a memory proposal, not just in the handoff.
