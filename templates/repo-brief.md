# Repo brief: <repo-id>

Written once per repo, reused by every agent deployed there. Its purpose is to
buy back the orientation budget an agent would otherwise spend rediscovering all
of this. Keep it under a page — a brief nobody reads costs more than it saves.

**Path:** `/abs/path` · **Branch:** `main` · **Role in this goal:** producer | consumer | both | independent

## What it is

<Two sentences. What this service or library does, and who calls it.>

## Build and test

```sh
install:   <cmd>
build:     <cmd>
test_one:  <cmd>     # use this during work
test:      <cmd>     # full suite, once before handoff
lint:      <cmd>
```

## Where things live

| Concern | Path |
|---|---|
| Entry point | |
| The area this goal touches | |
| Tests for it | |
| Config | |

## Conventions that differ from other repos in the workspace

<The ones that will actually trip an agent: error handling, module style, test
framework, naming, how config is read. Skip anything a linter enforces.>

## Landmines

<Files that look editable but are generated. Tests that are flaky. Anything that
has burned an agent before — cross-reference the memory id.>

## Ownership

<Who reviews here, what needs an ADR, what is off-limits.>
