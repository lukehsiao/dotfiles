---
name: conventional-pr-review
description: >
  Reviews one GitHub pull request in an isolated workspace and writes a markdown report of Conventional Comments anchored to file:line, with code sketches.
  Use when asked to review a PR by number, `owner/repo#N`, or URL, or to "write review comments" or "do a code review" of a PR.
  Language- and test-specific checks are delegated to companion skills such as review-rust and hegel-review.
---

# Conventional PR Review

Produce a rigorous, evidence-backed review of one pull request as a markdown report of [Conventional Comments](https://conventionalcomments.org/), each anchored to the exact file and line where it would be posted on GitHub.

## Inputs

- PR reference: number, `owner/repo#N`, or URL.
  Required.
- Output path: default `/tmp/pr-<N>-review.md`.

## Workflow

1. **Load companion skills that match the diff.**
   Read each before reviewing the code it governs, and state in the report which skills were applied and why others were skipped.
   - Rust code or API changes: `review-rust`.
   - Unit tests touching external I/O (network, fs, storage, clocks, browser APIs) or using mocks/spies: `nullables`.
   - Logic with invariants, parsers, serializers, state machines, merge/normalize functions, or property tests already present: `hegel` (and `hegel-review` when the PR adds property tests).
   - Always apply `software-design-philosophy` lenses (depth, information leakage, pass-throughs, special-casing).
   - Repo-scoped `AGENTS.md`/contributing docs for every touched directory.
2. **Isolate the checkout.**
   Never disturb the user's working copy.
   - Fetch the refs first: `gh pr view <N> --json headRefName,headRefOid,baseRefOid,isCrossRepository`.
   - jj, same-repo PR: `jj git fetch --remote origin --branch <headRefName>`, then `jj workspace add --name pr-<N> -r <headRefOid> /tmp/pr-<N>`.
   - Fork PR (`isCrossRepository: true`) or no jj: `git fetch origin pull/<N>/head:pr-<N>`, then `git worktree add /tmp/pr-<N> pr-<N>`.
   - Run every later command with `/tmp/pr-<N>` as the working directory.
   - Record `baseRefOid` and `headRefOid` in the report header.
3. **Map the change before judging it.**
   Read the PR metadata (`gh pr view <N>`), the full diff (`gh pr diff <N>`, or `jj diff --from 'fork_point(<baseRefOid> | <headRefOid>)' --to <headRefOid>` to match GitHub's merge-base diff), every changed file in full at head, and the immediate callers and callees of changed symbols (LSP references when available, otherwise grep).
   For large PRs, delegate parallel per-area slices to subagents and hand each the full comment format below.
4. **Run the gates.**
   Use the repo's documented task runner (for example `just` recipes named in `AGENTS.md`) on changed packages.
   Record exact commands and pass/fail.
   A failing gate is a finding; an unrun gate is stated with its reason.
5. **Probe suspected bugs.**
   For every claimed correctness issue, demonstrate it with a throwaway test, script, or REPL run in the PR workspace.
   Mark unverified claims `[INFERENCE]`.
   Delete scaffolding afterwards; never commit to the PR workspace.
6. **Write the report** (format below), then run the self-check.
7. Leave the workspace in place; give the user its path and the cleanup command (`jj workspace forget pr-<N> && rm -rf /tmp/pr-<N>`, or `git worktree remove /tmp/pr-<N> && git branch -D pr-<N>`).

## Review Lenses (priority order)

1. Correctness: edge cases, error paths, races, ordering, stale state, persisted/serialized data and its migration, off-by-one, clock misuse, unit mismatch.
2. Contracts: public API/type changes, every caller migrated, backwards compatibility of stored formats, config defaults.
3. Design: shallow modules, knowledge leaked across modules, temporal decomposition, booleans/config params that dodge a decision, dead code, duplicated logic.
4. Tests: do they catch plausible consumer-visible bugs?
   Flag tests that pin wording, wiring, or mock echoes; flag missing boundary/transition tests; suggest Nullables over mocks and property tests where an invariant exists.
5. Accessibility/UX (web), performance, security as applicable.
6. Docs, changelog/changeset, comments (why not what; no time-relative comments).

## Comment Format

Each comment is a heading anchor, then one or more prose paragraphs, then an optional fenced code sketch.
Every paragraph is written on a single line so it pastes cleanly into GitHub's comment box.

````markdown
### `path/to/file.ts:L42`

**issue(blocking):** Subject sentence. Why it matters and the evidence.

The concrete fix, in its own paragraph when it needs the room.

```ts
// sketch showing the bug or the suggested shape
```
````

Rules:

- Labels: `praise`, `nitpick`, `suggestion`, `issue`, `todo`, `question`, `thought`, `chore`, `note`, `typo`, `polish`.
- Decoration attaches with no space: `issue(blocking):`, `suggestion(non-blocking):`.
  Every comment carries exactly one of `blocking`/`non-blocking`.
- Anchor (`:L42` or `:L42-L57`) to the head-revision line where GitHub would place the comment, inside a diff hunk when possible.
  Verify line numbers by reading the file at head; never from memory.
- Every comment stands alone: never reference another comment ("see above", "as noted", "same as").
  Repeat needed context instead.
- Include a code sketch whenever it clarifies a suggestion or demonstrates an issue: a failing input, a reproduction, or the proposed shape.
  Keep it minimal and in the file's language.
- Blocking = incorrect behavior, data loss, contract break, failing gate, or a design choice expensive to undo later.
  Everything else is non-blocking.
- Evidence first: cite observed output, test runs, or code paths.
  Unverified = `[INFERENCE]`.
- Write to ASD-STE100 at about 80% strictness: short sentences, active voice, one idea per sentence, simple words over jargon, no em dashes, no filler.

## Report Skeleton

```markdown
# Review: <PR title> (#<N>)

- PR: <url>
- Base: <sha> · Head: <sha>
- Workspace: <path>
- Skills applied: <list, one-clause reason each>
- Gates: <command> → <result> (one bullet each)

## Summary

<What the PR does, the overall assessment, the count of blocking issues, and the top risks. Enough to orient a reviewer who has not read the diff, and no more.>

## Comments

<grouped by file in diff order, ascending line order within a file>
```

## Self-check Before Delivering

- [ ] Every comment has `label(blocking|non-blocking):` with no space before `(`.
- [ ] Every anchor line verified against head.
- [ ] No comment references another comment.
- [ ] Every comment paragraph is on a single line, with no hard wraps.
- [ ] Every correctness claim reproduced or marked `[INFERENCE]`.
- [ ] Gates recorded with real output.
- [ ] Throwaway probes removed from the workspace.
