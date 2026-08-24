# Definition of Done

A task is DONE only when **all** of these hold. Only the Manager sets DONE.

1. **Acceptance criteria met.** Every criterion in the task's
   `acceptance_criteria` is satisfied and demonstrably so — each one maps to a
   test, a check, or an explicit demonstration.
2. **Implemented in full.** No TODOs standing in for required behaviour, no
   stubbed paths, no commented-out code left behind. Anything deferred is written
   into the handoff as a named follow-up, not left implicit.
3. **Tested.** Unit tests for new logic, and the QE test plan executed. Tests run
   and pass; the output is attached. "Should pass" is not a result.
4. **Reviewed.** A Code Reviewer who is not the author has reported and has no
   unresolved `blocking` findings.
5. **Verified.** A QE Engineer who is not the author has run the plan against the
   acceptance criteria and reported PASS.
6. **No regressions.** The existing suite passes, or every failure is explained
   and accepted by the Manager on the record.
7. **Assumptions surfaced.** Every assumption made along the way appears in the
   final handoff. None are load-bearing and undocumented.
8. **Docs and interfaces updated** where the change alters a contract another
   agent or a user depends on.

## Not part of Done

- Unrelated cleanups. File them as follow-up tasks.
- Perfection. Meeting the criteria with acceptable, named debt is Done; the debt
  goes to the Architect as a follow-up, not into this task's scope.

## Failure states

- **FAILED** — QE or Review found a defect against the criteria. Returns to the
  Dev Engineer with the specific finding. Not a judgment on the agent; it is the
  system working.
- **BLOCKED** — waiting on a decision. Owned by whoever owns the answer.
- **DESCOPED** — the PM removed it. Only the PM may descope.

## Also required before DONE

9. **Spend reported honestly.** Every handoff and report carries its actual
   `SPEND` line. Inflated or invented figures corrupt every future task estimate
   the Manager makes.
10. **Memory captured.** Anything learned that would change how a future task runs
    — a human correction, a binding ruling, a dead end worth never repeating — is
    written to `memories/` before the agents are retired. Their context is
    discarded at retirement; what is not written is lost.

## Cost is part of Done

A task delivered at three times its budget is not cleanly done. It is delivered,
and it is also a scoping defect the Manager records — either the task was too
large, or the estimate was wrong. Both change how the next one is written.

This is never a reason to under-deliver against the criteria. It is a reason to
raise the sizing problem early, when it is still cheap to fix.
