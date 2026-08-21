# Rust Build and CI Performance Review

## Contents

- Core stance
- Find the real bottleneck
- Crate and dependency shape
- Compiler and linker choices
- Test and CI strategy
- Review smells
- Sources

## Core stance

- Prefer measuring before optimizing.
- Favor changes that improve the feedback loop for everyday development,
  not just one benchmarked CI job.
- Treat compile time and CI time as design feedback. They are often a
  sign of crate shape, dependency weight, feature sprawl, or test
  layout.

## Find the real bottleneck

- Prefer `cargo check` for fast local feedback when a full build is not
  required.
- Use timing and profiling tools before proposing structural changes:
  `cargo build --timings`, self-profile traces, `cargo llvm-lines`, and
  cargo fingerprint logging for unexpected rebuilds.
- Review whether the complaint is compile time, link time, test runtime,
  or CI queue time. The fix depends on which stage is slow.

## Crate and dependency shape

- Remove unused dependencies and disable unnecessary features.
- Review heavyweight crates and proc-macro-heavy dependencies with extra
  skepticism. They often dominate compile times.
- Consider splitting oversized crates into smaller workspace members when
  unrelated changes trigger broad rebuilds.
- Suggest feature-gating expensive functionality so common developer
  flows compile less code.
- Review generic APIs for monomorphization cost. If a wrapper is generic
  but the heavy work is not, move the heavy logic into a non-generic
  inner function.
- Prefer `cargo-hakari` or similar workspace unification tools only when
  the workspace is large enough to justify the extra complexity.

## Compiler and linker choices

- Prefer fast local-development defaults when they do not distort the
  product's behavior.
- Review linker choice when link time dominates. Faster linkers such as
  `lld` or `mold` can materially improve edit-build-run loops.
- Treat aggressive local-only compiler flags carefully. Suggestions like
  Cranelift or `target-cpu=native` can help, but they are environment-
  specific and should not leak into reproducible release settings.
- If proc macros dominate debug builds, consider whether build-override
  settings or dependency changes are the cleaner fix.

## Test and CI strategy

- Keep CI reproducible: prefer `--locked` and a clear separation between
  compile, lint, and test steps.
- Disable incremental compilation in CI unless there is a measured reason
  not to.
- Review whether debuginfo is unnecessarily inflating CI build cost for
  test-only jobs.
- Prefer `RUSTFLAGS=-D warnings` in CI over baking `deny(warnings)` into
  the crate, unless the project deliberately wants warnings to be part
  of the source contract.
- Use `cargo nextest` when test scheduling and reporting are a
  bottleneck.
- Combine integration tests into fewer binaries only when linking cost
  dominates and the test organization still stays understandable.
- Put unusually slow or external-environment tests behind a deliberate
  opt-in mechanism when they do not need to run on every local loop.
- Review caching strategy critically. Cargo caches, dependency caches,
  and container-layer caching can help, but they should not hide
  nondeterminism or stale lockfile problems.

## Review smells

- Build-time pain diagnosed purely by intuition with no timings.
- Broad dependencies or proc-macro crates added to hot-path workspace
  crates without discussing compile cost.
- Features always enabled even though only a small slice of the crate
  needs them.
- CI configured as one giant step with no visibility into compile,
  lint, and test costs.
- Local-optimization flags copied into release or shared CI settings
  without scoping.

## Sources

- Corrode, `Tips for Faster Rust Compile Times`:
  <https://corrode.dev/blog/tips-for-faster-rust-compile-times/>
- Corrode, `Tips for Faster CI Builds`:
  <https://corrode.dev/blog/tips-for-faster-ci-builds/>
- Corrode, `Long-Term Rust Maintenance`:
  <https://corrode.dev/blog/long-term-rust-maintenance/>
