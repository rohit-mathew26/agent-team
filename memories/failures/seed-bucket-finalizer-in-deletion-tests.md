---
id: mem-0007
type: failure
scope: container-object-storage-interface
source: code-reviewer#COSI-1
date: 2026-09-03
status: active
---

In BucketClaim reconciler tests, seed `cosiapi.ProtectionFinalizer` onto the
Bucket fixture before deleting it whenever a test must observe a Bucket in
deleting state (non-zero deletionTimestamp). Fixture Buckets carry no
finalizers by design — `generateIntermediateBucket` creates them purposefully
finalizer-less (the sidecar adds the finalizer in production) — so an unseeded
Bucket is removed instantly by `r.Delete` and any "still deleting" branch or
`bucketHasFinalizer` guard is silently dead code that passes green.

**Why:** A dev agent shipped a test block gated on `len(bucket.GetFinalizers()) > 0`
that never executed; reverting the production change still passed the suite.
Caught only because review empirically counted the branch's log line (0 hits).

**Applies when:** writing or reviewing tests for deletion paths in
`controller/pkg/reconciler/reconciler_test/` (or any COSI test needing a
Bucket that lingers after Delete). Reviewers: verify branch reachability
empirically (log-line count, or break-the-branch) rather than by reading.
