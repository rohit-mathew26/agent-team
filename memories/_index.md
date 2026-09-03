# Memory Index

One line per memory: `- [id] (type, scope) — the rule in one clause → file`

Loaded into every agent's context at spawn. Keep it terse; read the full entry
when a line touches your task.

<!-- Entries below. Newest last. Superseded entries are removed from the index
     but kept on disk. -->

- [mem-0001] (feedback, all) — Human feedback is distilled to its essence and recorded here, not kept as transcript → [feedback/distil-human-feedback.md](feedback/distil-human-feedback.md)
- [mem-0002] (ruling, container-object-storage-interface) — bucket_id is an opaque correlator; derive it from `name` in phase 1, apply parameters in phase 2 → [rulings/bucket-id-is-opaque-correlator.md](rulings/bucket-id-is-opaque-correlator.md)
- [mem-0003] (ruling, container-object-storage-interface) — static provisioning is outside 2-phase scope; no DriverGetBucket echo check → [rulings/static-provisioning-outside-2phase-scope.md](rulings/static-provisioning-outside-2phase-scope.md)
- [mem-0004] (feedback, all) — commit messages, PR descriptions, and changelogs must be strictly professional; no colloquial or idiomatic language → [feedback/commit-message-tone.md](feedback/commit-message-tone.md)
- [mem-0005] (feedback, all) — verify a finding's premise before promoting it to must-fix; unrelated cleanup gets its own PR → [feedback/validate-finding-premise.md](feedback/validate-finding-premise.md)
- [mem-0006] (feedback, all) — confirm published branch state with git ls-remote, not local tracking refs → [feedback/verify-remote-git-state.md](feedback/verify-remote-git-state.md)
