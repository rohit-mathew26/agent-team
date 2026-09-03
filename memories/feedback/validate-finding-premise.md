---
id: mem-0005
type: feedback
scope: all
source: human
date: 2026-08-25
status: active
---

Before promoting an advisory or nit-level review finding to must-fix, run the one
command that tests the premise it rests on. If the premise fails, the finding is a
separate PR, not part of this one. Keep every PR to its stated scope.

**Why:** Twice in the COSI two-phase provisioning work, a pre-existing unrelated
defect was admitted into a focused PR on a justification that was factually false,
and each was falsifiable in a single command: a CEL message "users now hit this"
(the sidecar's echo check fires first, so the rule never evaluates), and
`reserved 3;` "field numbering churned" (field 3 was never assigned, and sibling
messages share the gap unreserved). Neither was caught by review — only by the
human asking why the change was there.

**Applies when:** The Manager is triaging findings into fix tasks, or any agent is
about to act on a finding whose justification it has not verified. Corollary: when
the Architect and a Code Reviewer disagree on whether something is in scope for an
upstream PR, weight the narrower-scope position. Related:
[[static-provisioning-outside-2phase-scope]].
