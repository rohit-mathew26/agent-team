---
id: mem-0002
type: ruling
scope: container-object-storage-interface
source: product-manager
date: 2026-08-25
status: active
---

In COSI 2-phase provisioning, `bucket_id` is an opaque correlator, not the backend
bucket name. Identifier derivation belongs in phase 1 (`DriverGenerateBucketId`,
whose request carries `name` and nothing else); naming conventions, prefixes,
regions, and all other configuration belong in phase 2 (`DriverCreateBucket`),
where `parameters` is available. Do not add `parameters` to the phase-1 request.

**Why:** `bucket_id` is persisted immutable to `Bucket.status.bucketID`, but
BucketClass `parameters` are administrator-editable. A driver keying its ID on
parameters returns a different `bucket_id` after any class edit between the two
phases, permanently wedging the Bucket. Adding `parameters` as field 2 later is a
wire-compatible additive proto3 change, so deferring is reversible while shipping
the field is not.

**Applies when:** Anyone proposes plumbing BucketClass parameters into phase 1, or
a driver author asks where to apply a naming convention.
