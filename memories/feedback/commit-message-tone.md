---
id: mem-0004
type: feedback
scope: all
source: human
date: 2026-08-25
status: active
---

Word every commit message strictly professionally. Avoid colloquial, idiomatic,
and figurative language entirely — state the technical fact plainly instead. This
covers the subject line, body, and RELEASE NOTE sections, and applies equally to
PR descriptions and changelog entries.

**Why:** These commits land in upstream public repositories (Kubernetes
SIG-Storage and similar) and are read by external contributors. Idiom is
imprecise, ages badly, and cannot be rewritten once merged.

**Applies when:** Any agent drafts a commit message, PR description, or changelog
entry. Rejected example, 2026-08-25: "COSI has no capability negotiation, so this
is a flag day" — the literal consequence was already stated in the next sentence,
so the idiom carried no information. Prefer "this is a breaking change for
third-party drivers"; prefer "the request fails without retrying" over "the bucket
gets wedged".
