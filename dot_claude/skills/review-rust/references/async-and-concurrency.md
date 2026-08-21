# Rust Async and Concurrency Review

## Contents

- Core stance
- Async API boundaries
- Task lifetime and cancellation
- Blocking and shared state
- Trait and thread-safety expectations
- Review smells
- Sources

## Core stance

- Be explicit about where concurrency starts and what runtime model it
  depends on.
- Review cancellation behavior as part of correctness, not as an edge
  case.
- Prefer simpler sync code when async does not materially improve the
  design.

## Async API boundaries

- Be conservative about exposing `async` in public APIs. Runtime-coupled
  interfaces are maintenance commitments.
- Keep core domain logic runtime-agnostic where practical, and isolate
  async adapters near IO boundaries.
- Prefer documenting whether a function is cancellation-safe, blocking,
  or executor-specific when those details matter to callers.

## Task lifetime and cancellation

- Review whether spawned tasks have a clear owner, shutdown path, and
  error reporting path.
- Treat detached tasks with extra skepticism. Silent background work is
  a common source of leaks and shutdown bugs.
- Review `select!` loops for cancellation safety. Dropping unfinished
  futures can lose progress or messages when the underlying operation is
  not cancellation-safe.
- Review fairness and starvation risks in `select!` usage, especially
  when one branch is frequently ready.
- Prefer explicit cancellation primitives and shutdown signaling over
  ad hoc task abandonment.

## Blocking and shared state

- Use `spawn_blocking` or an equivalent boundary for blocking work in
  async contexts.
- Do not hold locks or other scarce resources across `.await` unless the
  design clearly requires it and the implications are understood.
- Review channel and queue choices for backpressure. Unbounded channels
  are policy decisions, not harmless defaults.
- Prefer message passing or narrowly-scoped shared state over broad
  shared mutable structures.

## Trait and thread-safety expectations

- Review `Send` and `Sync` expectations on public types, especially when
  raw pointers, interior mutability, or executor affinity are involved.
- Prefer tests or compile-time assertions that make thread-safety
  expectations explicit when they are part of the contract.
- Review whether trait objects, futures, and callback types expose the
  intended thread-safety guarantees.

## Review smells

- Async added to CPU-bound or purely local code with no clear benefit.
- Spawned tasks whose handles are dropped immediately without a clear
  shutdown story.
- `select!` used in loops without considering cancellation safety.
- Blocking filesystem, compression, or crypto work on the async
  executor.
- Locks, permits, or transactions held across `.await`.
- Public APIs that accidentally commit callers to a specific runtime.

## Sources

- Async Book:
  <https://rust-lang.github.io/async-book/>
- Tokio, `select!` macro docs:
  <https://docs.rs/tokio/latest/tokio/macro.select.html>
- Tokio, `Bridging with sync code`:
  <https://tokio.rs/tokio/topics/bridging>
- Rust API Guidelines, `Interoperability`:
  <https://rust-lang.github.io/api-guidelines/interoperability.html>
- Corrode, `Long-Term Rust Maintenance`:
  <https://corrode.dev/blog/long-term-rust-maintenance/>
