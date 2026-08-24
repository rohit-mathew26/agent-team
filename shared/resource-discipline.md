# Resource Discipline

Cycles, tokens, and wall-clock time are the team's scarcest resources. You are
personally accountable for the ones you spend. An agent that reaches the right
answer wastefully has done the job badly.

## The budget

Every task carries a budget. Defaults, unless your task says otherwise:

| Resource | Default | Meaning |
|---|---|---|
| `tool_calls` | 40 | Reads, searches, commands, fetches — combined |
| `commands` | 10 | Of those, actual executions (build, test, run) |
| `wall_clock_minutes` | 20 | Start to handoff |
| `messages_out` | 8 | Messages you send to other agents |

Rules:

- **Warn at 70%.** Send a `BUDGET` message to the Manager: what is consumed, what
  remains undone, whether you will finish.
- **Stop at 100%.** Do not silently exceed. Report what you completed, what is
  left, and request an extension **with a reason and an amount**. An overrun you
  did not flag is treated as stuck.
- **Under budget is not a target to fill.** Finishing at 12 of 40 calls is a good
  outcome, not a sign you cut corners.

## Before every tool call

Ask: *what decision does this output change?* If the answer is "none", do not
make the call.

- **Do not execute to confirm what you already know.** Re-running a passing test
  you have not changed is a wasted cycle.
- **Do not fetch data you will not read.** No speculative dumps, no "let me look
  around first."
- **Do not re-read a file you have already read** in this task unless you changed
  it. You have it.
- **Do not verify by re-reading your own edit.** The edit tool already failed loudly
  if it did not apply.
- **Never `cat` a large file to find one thing.** Search for the symbol, then read
  the region around it.
- **Batch independent calls.** Three unrelated searches go out together, not in
  three sequential turns.

## Reading efficiently

1. Search first, read second. `grep`/symbol search to locate, then a bounded read
   around the hit.
2. Read the narrowest unit that answers the question: the function, then its
   callers, then the file — stop as soon as you can act.
3. Prefer one targeted read over three exploratory ones.
4. Stop reading when you can act. Completeness for its own sake is waste.

## Executing efficiently

Commands are the most expensive calls you make. Every execution must have a
stated purpose.

- **Run the narrowest thing that proves the point:** the one test file, not the
  whole suite — until the final pre-handoff run, which is the whole suite once.
- **Form a hypothesis before you run.** "I expect X; if I see Y the cause is Z."
  Running the same command a third time without a changed hypothesis is a stuck
  trigger, not persistence.
- **Read the whole output the first time.** Re-running because you skimmed is a
  wasted cycle.
- **Never run a command whose result you can derive from one you already ran.**

## Thinking efficiently

- Decide routine things immediately: naming, local structure, which of two
  equivalent in-repo helpers. Deliberating on a reversible choice is waste.
- Spend the deliberation on the irreversible: data shape, public interface,
  anything another agent will build against.
- If you have gone two cycles without changing your plan or your evidence, you are
  spinning. Say so — see `lifecycle.md`.

## The waste ledger

These are the team's most common wasted cycles. Do not contribute to them.

| Waste | Instead |
|---|---|
| Exploring the repo without a question | Know what you are looking for before you look |
| Re-deriving a fact already in the task brief | The brief is authoritative; use it |
| Asking a question the PRD or an ADR answers | Search those first; your `TRIED` line must show it |
| Running the full suite on every small edit | Narrow run during work, full run once at the end |
| Fixing things outside the task | `SCOPE_CHANGE` message, then keep going |
| Producing a long report nobody needs | Conclusion, evidence, done |
| Polishing past the acceptance criteria | Criteria met is finished |
| Waiting idle on an answer | Do everything that does not depend on it, then report BLOCKED |

## Report your spend

Every `HANDOFF` and `REPORT` ends with one line:

```
SPEND: <tool_calls>/<budget> calls, <commands> commands, <minutes>m
```

The Manager uses this to size the next task. Inflated or invented numbers corrupt
every future estimate.
