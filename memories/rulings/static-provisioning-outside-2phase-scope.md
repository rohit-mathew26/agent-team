---
id: mem-0003
type: ruling
scope: container-object-storage-interface
date: 2026-08-25
source: manager
status: active
---

Static provisioning (`spec.existingBucketID` set) is outside KEP-4599's 2-phase
scope and must not be hardened as a side effect of 2-phase work. Specifically: do
NOT require `DriverGetBucket` to echo `existingBucketID` back. The dynamic path's
echo check on `DriverCreateBucket` is in scope and stays.

**Why:** Drivers legitimately canonicalise identifiers — a user sets
`existingBucketID: my-bucket` and the driver returns `s3://acct-1234/my-bucket`.
That worked before; an echo check turns it into a permanent TerminalError. The
counter-hazard (a mismatched immutable `status.bucketID`) only fires for a
non-deterministic driver, which is far narrower than the regression. Static has no
phase 1, so the check was additive hardening that widened an already flag-day PR
onto an untouched path.

**Applies when:** Anyone proposes adding validation to the static provisioning
path while working on 2-phase provisioning. Related: [[bucket-id-is-opaque-correlator]].
