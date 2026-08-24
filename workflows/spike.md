# Workflow: Spike

A time-boxed investigation. The deliverable is a **decision-ready answer**, never
production code.

```
Open question (from PM: "is this feasible?" / from Architect: "which approach?")
     |
     v
[Manager] writes the spike task:
     - the QUESTION, stated so it can be answered yes/no or A/B
     - the DECISION it unblocks
     - the TIME BOX
     - what evidence would be sufficient
     v
[Dev] investigates: reads code, prototypes THROWAWAY, measures
     |    - prototype code is never merged
     |    - stop at the time box even if unresolved; a partial answer with
     |      known unknowns beats an over-run
     v
[Dev] reports FINDINGS (format below)
     |
     v
[Architect] rules (technical) or [PM] rules (product) on the finding
     |
     v
[Manager] converts the ruling into real tasks, or closes the question
```

## Findings format

```
QUESTION:    <as asked>
ANSWER:      <direct answer — yes/no/A/B. Lead with it.>
CONFIDENCE:  high | medium | low, and what would raise it
EVIDENCE:    <what you actually ran or read; paths, measurements, output>
COST:        <rough effort for each viable option>
RISKS:       <what could still go wrong with the recommended path>
UNKNOWNS:    <what the time box did not let you resolve>
```

## Rules

- **The time box is hard.** Stop and report. Ask for an extension with a reason;
  do not take one.
- **Prototype code is thrown away.** It was written without tests, review, or
  criteria. Merging it launders unreviewed code into the product.
- **A spike never becomes the implementation task.** The Manager writes a fresh
  task from the ruling.
- **"I don't know" is a valid answer** when it comes with `UNKNOWNS` and what it
  would take to find out.

## Cost discipline

A spike is a budget with a question attached. The box is the point.

- **The time box and the tool-call budget are both hard.** Stop at either and
  report what you have. Ask for an extension with a specific amount and a reason;
  never take one.
- **A partial answer with named unknowns is a valid deliverable.** It lets the
  Architect or PM decide, which is what the spike was for.
- **Ask before you excavate.** If the Architect or PM already knows the answer,
  one message ends the spike. Check that first — it is the cheapest possible
  outcome.
- **Prototype code is thrown away.** It was written without tests, review, or
  criteria; merging it launders unreviewed code into the product.
- **A spike never becomes the implementation task.** The Manager writes a fresh,
  tightly scoped task from the ruling.
- **Report the spend.** A spike's cost is data the Manager uses to size the next
  one.

Spike findings that will outlive the task — a library that does not work here, an
approach that cannot scale — belong in `memories/`, not only in the report.
