# Workflow: Bug Fix

Differs from feature delivery in one crucial way: **the failing test comes
first**, and QE writes it.

```
Bug report (human, QE, or production signal)
     |
     v
[Manager] triage: is the expected behaviour actually specified?
     |         no -> QUESTION to PM: "is this a bug or unspecified behaviour?"
     |                The PM's answer becomes the acceptance criterion.
     v
[QE] reproduces; writes a FAILING test that captures the defect
     |     cannot reproduce -> back to reporter with what was tried; do not
     |                          "fix" an unreproduced bug
     v
[Manager] assigns to a Dev Engineer, with the failing test as the criterion
     |
     v
[Dev] finds the ROOT CAUSE, states it, then fixes it
     |    - the failing test must pass
     |    - no other test may be weakened or deleted
     |    - a symptom-level patch requires an explicit Architect ruling
     v
[Reviewer] reviews the fix AND the root-cause claim
     |         "does this fix the cause or hide the symptom?"
     v
[QE] runs the new test + regression around the change
     |
     v
[Manager] DONE
```

## Severity drives the path

| Severity | Path |
|---|---|
| **Critical** (data loss, security, outage) | Manager escalates to human immediately; Architect rules on containment; fix and full review still required — no skipping the gate |
| **Major** | Standard path above, prioritised ahead of feature work |
| **Minor** | Queued; the PM decides whether it displaces feature work |

## Rules

- **No fix without a reproduction.** An unreproduced bug is a hypothesis.
- **No fix without a regression test.** The test is what stops it recurring; the
  code change alone is not the deliverable.
- **State the root cause in the handoff.** "Added a null check" is not a root
  cause. Why was it null?
- **Related bugs found along the way are new tasks**, not scope on this one.

## Cost discipline

Bug fixes are where budgets are most often blown, because debugging invites
repetition.

- **Reproduction is capped.** If QE cannot reproduce inside its budget, that is a
  finding — report "not reproducible, here is what was tried" and stop. Do not
  keep hunting; an unreproduced bug is a hypothesis, and the PM decides whether it
  is worth more money.
- **Every run needs a changed hypothesis.** Three runs of the same command with
  the same theory is a stuck trigger, not diligence.
- **The failing test is the budget's anchor.** Once it exists, the Dev's job is
  narrow and cheap: make that one test pass without weakening others.
- **QE and Dev talk directly.** The Dev asks QE for the exact repro state; QE asks
  the Dev what the root cause was. Neither goes through the Manager.
- **Root cause is stated, not implied.** "Added a null check" is not a root cause.
  Why was it null? A symptom patch requires an explicit Architect ruling.
- **Related bugs found on the way are `SCOPE_CHANGE` messages**, never absorbed.

If the root cause turns out to be a class of defect rather than one instance, that
is a `MEMORY` proposal — the next agent should not rediscover it.
