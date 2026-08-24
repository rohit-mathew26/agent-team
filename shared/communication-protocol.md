# Communication Protocol

## Topology: mesh, with Manager visibility

Any agent may message any other agent directly. A Dev Engineer with a product
question asks the Product Manager. A Reviewer unsure about a boundary asks the
Architect. A QE Engineer needing a repro detail asks the Dev who wrote it. No
relay hop, no queue behind the Manager.

```
        Product Manager <————————————> Architect
              ^   ^                      ^   ^
              |   \                     /    |
              |    \                   /     |
              |     v                 v      |
              |   Dev <——————> QE <——————> Reviewer
              |         \       |       /
              v          v      v      v
        ————————————— Manager ——————————————
        (sees: RULING, BLOCKED, HANDOFF, SCOPE_CHANGE, CONFLICT)
```

The Manager is not a relay. The Manager is the **resolver** — of conflict, of
resourcing, of sequencing — and the only path to a human.

### Manager visibility

CC the Manager on exactly these message types:

| Type | Why the Manager needs it |
|---|---|
| `RULING` | It binds other agents; the Manager propagates it |
| `BLOCKED` | Blocked work is the Manager's top priority |
| `HANDOFF` | It advances task state |
| `SCOPE_CHANGE` | It changes cost and sequencing |
| `CONFLICT` | Only the Manager resolves it |

Ordinary Q&A between agents is **not** cc'd. That traffic belongs to the agents
having it, and copying the Manager on it wastes the context the Manager needs for
sequencing. If an answer turns out to bind future work, the answering singleton
raises it as a `RULING` — that is the message the Manager sees.

## Message envelope

```
FROM:    <role>#<instance-id>
TO:      <role>#<instance-id>
CC:      manager            # only for the five types above
TASK:    <task-id>          # or NONE
TYPE:    ASSIGN | QUESTION | ANSWER | HANDOFF | BLOCKED | REPORT
         | PROGRESS | RULING | CONFLICT | SCOPE_CHANGE | BUDGET
```

Body shapes:

- **ASSIGN** — a task object valid against `schemas/task.schema.json`, including
  its budget.
- **QUESTION** — one question, the decision it unblocks, the options you see,
  your recommendation. Addressed to the owner directly.
- **ANSWER** — the decision, the reasoning in a few lines, and whether it binds
  future work.
- **HANDOFF** — the artifact, what changed, what the receiver must do, every open
  assumption.
- **BLOCKED** — what you cannot pass, what you tried, who owns the answer, what
  you completed anyway.
- **PROGRESS** — see `lifecycle.md`. Due every 10 tool calls. Three lines.
- **BUDGET** — a warning at 70% consumed, or a request for an extension with a
  reason and an amount.
- **CONFLICT** — two positions that cannot both hold, stated fairly, to the
  Manager.
- **RULING** — a binding decision. From the Manager (conflict), the PM (product),
  or the Architect (technical).
- **SCOPE_CHANGE** — work discovered that is not in the task. Never absorbed
  silently.

## Message economy

Every message you send costs another agent's context and attention. Treat the
send button as expensive.

1. **Read before you ask.** If the answer is in the code, the PRD, an ADR, or a
   prior ruling, find it. A question whose answer was already written wastes two
   agents instead of one — and counts toward a stuck determination.
2. **Ask the owner, not the room.** No broadcasts. One recipient per question.
3. **One question per message.** Batch only questions that share a single answer.
4. **Lead with the ask.** First line states what you need. No preamble, no
   restating the assignment, no closing summary.
5. **Answer in the shape the asker can act on.** A decision, not a survey.
6. **Do not thank, acknowledge, or confirm receipt.** State transitions are the
   acknowledgement.
7. **Do not re-ask an answered question.** If the answer was ambiguous, quote it
   and ask the narrower follow-up once.
8. **Stay inside `messages_out`.** Hitting the cap means you are conversing
   instead of working.

## Rules

1. **One task per message.**
2. **State transitions are announced,** never silent.
3. **Answers are quoted, not paraphrased,** when passed on.
4. **No fabricated authority.** Never "the Architect said" or "per the PRD"
   without a reference to the actual message, ADR, or PRD section.
5. **Silence is not consent.** If you need an answer to proceed, report BLOCKED —
   to the owner, cc the Manager.
6. **Peer answers are not rulings.** Another Dev's opinion does not bind you. Only
   the PM (product), the Architect (technical), and the Manager (conflict) issue
   binding answers.
