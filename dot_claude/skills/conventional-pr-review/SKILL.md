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
   - Added or changed tests: `tdd`, for what a good test is and its anti-patterns.
   - Changes to `AGENTS.md`, `CLAUDE.md`, or a skill: `writing-for-agents`.
   - Always apply `codebase-design` for the design vocabulary, and `code-review` for its smell baseline and Spec axis.
     Read both as reference; this skill's workflow and comment format still govern.
   - Repo-scoped `AGENTS.md`/contributing docs for every touched directory.
   - `GLOSSARY.md` (or `GLOSSARY-MAP.md`) and ADRs for touched areas, when they exist.
     Flag names that conflict with the glossary, and treat decisions an ADR records as settled.
     A missing glossary or ADR is not a finding.
2. **Isolate the checkout.**
   Never disturb the user's working copy.
   - Read the PR's refs first: `gh pr view <N> --json headRefName,headRefOid,baseRefOid,isCrossRepository,headRepository,headRepositoryOwner`.
   - Same-repo PR: `jj git fetch --remote origin --branch <headRefName>`.
   - Fork PR (`isCrossRepository: true`): the head is not a branch on origin, so add the fork as a remote first: `jj git remote add pr-<N> https://github.com/<headRepositoryOwner.login>/<headRepository.name>`, then `jj git fetch --remote pr-<N> --branch <headRefName>`.
   - Either way, take the workspace from the fetched commit: `jj workspace add --name pr-<N> -r <headRefOid> /tmp/pr-<N>`.
   - Run every later command with `/tmp/pr-<N>` as the working directory.
   - Record `baseRefOid` and `headRefOid` in the report header.
3. **Map the change before judging it.**
   Read the PR metadata (`gh pr view <N>`), the spec (the PR body plus each issue in `gh pr view <N> --json closingIssuesReferences`), the full diff (`gh pr diff <N>`, or `jj diff --from 'fork_point(<baseRefOid> | <headRefOid>)' --to <headRefOid>` to match GitHub's merge-base diff), every changed file in full at head, and the immediate callers and callees of changed symbols (LSP references when available, otherwise grep).
   For large PRs, delegate parallel per-area slices to subagents.
   Hand each the full comment format below, the spec, the design pass questions from step 6, and the companion skills chosen in step 1, which each subagent loads itself.
   Each subagent returns its slice's Design pass rows; merge them, then check locality across slices, since a rule split across two slices is invisible to both.
4. **Run the gates.**
   Use the repo's documented task runner (for example `just` recipes named in `AGENTS.md`) on changed packages.
   Record exact commands and pass/fail.
   A failing gate is a finding; an unrun gate is stated with its reason.
   When the diff touches code the repo benchmarks, run those benches at base and at head, and record both numbers.
5. **Probe suspected bugs and slowdowns.**
   For every claimed correctness issue, build a tight, red-capable loop in the PR workspace and minimize it, following Phases 1 and 2 of `diagnosing-bugs`.
   For every claimed performance issue, measure it on representative input: reuse the step 4 bench numbers when they cover the path, or else build a tight micro-benchmark or timed run that shows the cost grow with input size or differ from base.
   Repeat each measurement, and quote the numbers and their spread in the comment.
   When no loop is reachable, prefix the unverified statement with `[UNVERIFIED]` and continue; this replaces the Phase 1 instruction to stop and ask the user.
   When the bug has no correct seam for a regression test (as `diagnosing-bugs` Phase 5 defines it), report that as a design finding.
   Delete scaffolding afterwards; never commit to the PR workspace.
6. **Run the design pass.**
   List every module the diff adds or widens: a function, type, process step, route, or CLI flag.
   For each module, answer every question below in `codebase-design` terms, and record each answer in the report's Design pass table as `clean` or the anchor of the comment it produced:
   - Interface: what must a caller now know that it did not know before? Look for an ordering rule, a config flag, an error mode, or a meaning carried by `None`, a sentinel, or a boolean.
   - Depth: does the module pass the deletion test, or is it a pass-through?
   - Locality: does one rule now live at more than one site? Name every site.
   - Seam: how many adapters sit at each new seam? One adapter means a hypothetical seam.
   - Invalid states: which inputs can a caller combine that mean nothing?
   - Shape: does a smaller, more boring shape meet the same spec, such as existing code reused or one convention where the PR adds a second?

   Then go back over every correctness and contract finding and find its **root cause**.
   When a design choice produced the finding, the comment names that choice as the root cause and gives the **symptom** as its evidence.
   The pass is done when every module has an answer to every question.
7. **Write the report** (format below), then run the self-check.
8. Leave the workspace in place; give the user its path and the cleanup commands (`jj workspace forget pr-<N> && rm -rf /tmp/pr-<N>`, plus `jj git remote remove pr-<N>` for a fork PR).

## Review Lenses (priority order)

1. Correctness: edge cases, error paths, races, ordering, stale state, persisted/serialized data and its migration, off-by-one, clock misuse, unit mismatch.
2. Spec: requirements from the spec that are missing, partial, or wrong, and behavior nobody asked for (scope creep).
   Quote the requirement in the comment.
   When neither the PR body nor a linked issue states requirements, skip this lens without asking the user, and record `Spec: none` in the report header.
3. Contracts: public API/type changes, every caller migrated, backwards compatibility of stored formats, config defaults.
4. Design: the findings of the design pass (step 6), tests that reach past the interface, and dead code.
   Then the `code-review` smell baseline: name the smell and quote the hunk.
   Every smell is `non-blocking`; a widened or leaky public interface follows the blocking rule below.
5. Performance: algorithmic complexity on inputs that grow, I/O or queries inside loops, blocking calls on async or hot paths, unbounded buffers, caches, and queues, avoidable allocation and copying on hot paths, and lock scope.
   Weigh each cost against how hot the path is.
6. Tests: do they catch plausible consumer-visible bugs?
   Judge them against the good test and the anti-patterns in `tdd`.
   Flag missing boundary/transition tests.
   Suggest Nullables over mocks, and property tests where an invariant exists.
7. Accessibility/UX (web) and security as applicable.
8. Docs, changelog/changeset, comments (why not what; no time-relative comments).

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
- Blocking = incorrect behavior, data loss, contract break, failing gate, a missing or wrong spec requirement, a broken performance budget, a repeatable and material regression on a hot path that the PR's correctness gains do not justify, or a design choice expensive to undo later.
  Everything else is non-blocking.
- Evidence first: cite observed output, test runs, bench numbers, or code paths.
  Prefix every claim you did not observe with `[UNVERIFIED]` directly before the unverified statement so the reader sees the caveat upfront.
- Write to ASD-STE100 at about 80% strictness: short sentences, active voice, one idea per sentence, simple words over jargon, no em dashes, no filler.

## Report Skeleton

```markdown
# Review: <PR title> (#<N>)

- PR: <url>
- Base: <sha> · Head: <sha>
- Workspace: <path>
- Spec: <PR body and linked issues that state requirements, or `none`>
- Skills applied: <list, each with the comment anchors or report section it produced, or `no finding`>
- Gates: <command> → <result> (one bullet each)

## Summary

<What the PR does, the overall assessment, the count of blocking issues, and the top risks. Enough to orient a reviewer who has not read the diff, and no more.>

## Design pass

| Module | Interface | Depth | Locality | Seam | Invalid states | Shape |
| --- | --- | --- | --- | --- | --- | --- |
| <path:symbol> | <`clean` or comment anchor> | ... | ... | ... | ... | ... |

## Comments

<grouped by file in diff order, ascending line order within a file>
```

## Self-check Before Delivering

- [ ] Every comment has `label(blocking|non-blocking):` with no space before `(`.
- [ ] Every anchor line verified against head.
- [ ] No comment references another comment.
- [ ] Every comment paragraph is on a single line, with no hard wraps.
- [ ] Every correctness claim reproduced and every performance claim measured, or prefixed with `[UNVERIFIED]` before the unverified statement.
- [ ] The Design pass table has a row for every module the diff adds or widens, and no blank cell.
- [ ] Every correctness and contract comment that a design choice caused names that choice as its root cause.
- [ ] Every skill under Skills applied names the output it produced, or `no finding`.
- [ ] Gates recorded with real output.
- [ ] Throwaway probes removed from the workspace.
