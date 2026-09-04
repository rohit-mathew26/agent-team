# Escalation

## Decide, then ask, then escalate

Three tiers, in order of cost. Use the cheapest one that resolves it.

1. **Decide it yourself.** Routine, reversible judgment calls — naming, local
   structure, which of two equivalent in-repo helpers. Make the call, note it in
   your handoff, move on. Deliberating here is waste.
2. **Ask the owner directly.** Two readings lead to materially different work, and
   a specific role owns the answer. Message them; no relay.
3. **Raise a conflict to the Manager.** Two parties disagree, or two binding
   answers cannot both hold. Only the Manager resolves this.

Escalate on **ambiguity**, not on difficulty. Hard is your job.

## Routing: ask the owner, directly

| Kind of question | Ask | Example |
|---|---|---|
| What should it do? In scope? Priority? | **Product Manager** | "Expired token: retry or re-login?" |
| How should it be built? Which boundary? Is this debt acceptable? | **Architect** | "Gateway or service?" |
| A fact about a change someone else made | **That agent, directly** | QE asking the Dev for a repro detail |
| Budget, sequencing, another agent, rescope | **Manager** | "This needs 3x the budget" |
| Two answers that cannot both hold | **Manager** — `CONFLICT` | "The PM requires realtime; the Architect says the store can't" |

Before asking anything: **search first**. The PRD, the ADRs, the task brief, the
memories index, the code. A question whose answer was already written costs two
agents and counts toward a stuck determination. Your `TRIED` line must show where
you looked.

Ask **once**. If the answer was ambiguous, quote it and ask the narrower
follow-up. Re-asking the same question is a stuck trigger.

## BLOCKED message

```
TYPE: BLOCKED
TO:        <the owner of the answer>
CC:        manager
BLOCKER:   <the one thing you cannot resolve>
DECISION:  <the fork it unblocks — concretely>
OPTIONS:   <2-3 realistic paths and the consequence of each>
RECOMMEND: <your pick and why, one line>
TRIED:     <where you already looked>
COMPLETED: <everything you finished that does not depend on the answer>
SPEND:     <calls>/<budget>, <commands> commands, <minutes>m
```

`COMPLETED` is mandatory. Being blocked on one branch is never a reason to idle
on the others — and idling burns wall-clock budget for nothing.

## Conflict resolution

Any party may raise a `CONFLICT`: a Dev against an Architect ruling, the PM
against the Architect, a Reviewer against a PM criterion, QE against a Dev's
claim. The Manager resolves all of them.

Raise it as:

```
TYPE: CONFLICT
TO:        manager
PARTIES:   <who holds which position>
POSITION_A:<stated fairly, in its own best terms>
POSITION_B:<stated fairly, in its own best terms>
STAKE:     <what is blocked until this resolves>
COST:      <what each path costs, if you know>
```

State the other side's position as well as they would. A conflict raised as a
strawman gets ruled against on the facts you left out.

The Manager returns a `RULING`. **A ruling is binding and is not re-litigated.**
If new evidence genuinely invalidates it, raise a new conflict citing that
evidence — not the same argument again.

## Human escalation

Only the Manager escalates to the human operator. Triggers:

- Deadlock persisting after a Manager ruling.
- A task that has exhausted two respawns.
- A budget request beyond `task_max`.
- **Anything safety-shaped:** data loss, credential exposure, destructive
  migration, an outward-facing action. Stop and ask, regardless of how clear the
  instruction looked.
- **A large strategic decision** whose consequences reach beyond the codebase:
  open-sourcing or publishing a repo, license choice, vendor or paid-service
  commitments, platform adoption, anything legal or public-facing. The
  Architect frames the options; the human decides.
- Requirements and feasibility irreconcilable within budget.
- The same decision generating conflict twice.

Format:

```
TYPE: ESCALATION
TRIGGER:   <which of the above>
SITUATION: <3 lines maximum>
POSITIONS: <each party's view, stated fairly>
OPTIONS:   <what can be done, with cost>
RECOMMEND: <the Manager's pick, last>
COST_SO_FAR: <spend on this thread to date>
```

Recommendation goes last, after the human has the facts. Never escalate without
one.
