---
name: review-rust
description: Review Rust code, diffs, pull requests, and API designs for correctness, idiomatic style, maintainability, and type-driven design. Use when Codex is asked to audit Rust changes, review a Rust refactor, assess whether Rust code is idiomatic, or explain Rust-specific design and correctness concerns in existing code.
---

# Review Rust

## Overview

Review Rust with a bias toward correctness first, then API design,
maintainability, and idiomatic style. Favor concrete findings tied to
code locations and explain the Rust-specific principle behind each
finding.

## Workflow

1. Establish local context before judging style. Identify crate type,
   public API surface, edition, enabled lints, tests, feature flags,
   `unsafe`, async/concurrency usage, and whether the change is a
   prototype or production path.
2. Prioritize correctness and failure modes. Look for panics,
   unchecked indexing, surprising `Drop` behavior, cancellation issues,
   invalid assumptions hidden in `unsafe`, and API changes that can
   silently break callers.
3. Review type design and invariants. Prefer types that make invalid
   states hard or impossible to represent, and question structs that
   rely on comments, booleans, or loosely-related `Option` fields to
   stay valid.
4. Review ownership and API ergonomics. Treat explicit lifetimes,
   over-generic signatures, and unnecessary borrowing complexity as
   design smells unless they clearly pay for themselves.
5. Review clarity and idioms. Prefer simple code, explicit imports,
   expressions over placeholder mutation, and iterator chains only when
   they improve readability instead of obscuring it.
6. Run the smallest relevant checks when possible. Prefer targeted
   commands such as `cargo test`, `cargo clippy --all-targets
   --all-features`, and `cargo fmt --check`. If checks are skipped,
   say why.

## Findings

- Lead with issues that can cause bugs, soundness problems, panic
  paths, API hazards, or future maintenance traps.
- Cite file and line locations whenever possible.
- Explain impact, not just preference. Distinguish correctness issues
  from taste.
- If the code is intentionally prototype-grade, keep the review aligned
  with that bar while still calling out anything that will block
  hardening or shipping.
- If no findings remain, say so explicitly and note any residual risk
  from missing tests, unchecked assumptions, or skipped verification.

## References

Read `references/corrode-idioms.md` when the review touches API design,
state modeling, invariants, ownership, or defensive programming.

Read `references/suggested-lints.md` when the review turns into lint
policy, CI guidance, or "can the compiler catch this for us?" design.

Read `references/idiomatic-control-flow.md` when the review is about
iterator style, `Option` and `Result` handling, `match`, `if let`,
`let-else`, let chains, or expression-oriented Rust.

Read `references/maintenance-and-lifecycle.md` when the review touches
dependency policy, public API stability, async boundaries, documentation,
unsafe containment, or long-term maintainability tradeoffs.

Read `references/build-and-ci-performance.md` when the review touches
compile times, CI throughput, crate structure, feature flags, test
layout, or build-system choices that affect Rust feedback loops.

Read `references/security-and-boundaries.md` when the review touches
deserialization, secrets, numeric conversions, filesystem behavior, FFI,
network boundaries, or "safe Rust" code that can still fail badly.

Read `references/prototype-and-simplicity.md` when the review needs to
separate prototype shortcuts from production debt, or when code feels
over-engineered and the right advice is to simplify before abstracting.

Read `references/async-and-concurrency.md` when the review touches task
lifetimes, cancellation, `select!`, shared state, blocking in async
contexts, runtime coupling, or `Send` and `Sync` expectations.

Read `references/public-api-and-error-design.md` when the review touches
public surface area, error types, semver risk, trait design, dependency
types leaking through APIs, or application-vs-library error boundaries.

Read `references/tooling-cheatsheet.md` when the review should suggest a
concrete tool or command for semver checks, public API diffs, supply
chain checks, docs verification, release automation, or performance
investigation.

Read `references/docs-and-publishing.md` when the review touches
rustdoc quality, doctests, intra-doc links, docs.rs metadata, package
verification, or crates.io publishing readiness.
