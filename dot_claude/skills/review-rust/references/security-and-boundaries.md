# Rust Security and Boundary Review

## Contents

- Core stance
- Numeric and conversion safety
- Secrets and serialization
- Filesystem and process boundaries
- API and boundary review
- Review smells
- Sources

## Core stance

- Treat "safe Rust" as memory-safe, not automatically secure or correct.
- Review boundary code more strictly than pure internal logic.
- Prefer designs that make unsafe or invalid boundary states hard to
  represent.

## Numeric and conversion safety

- Review integer arithmetic for overflow assumptions. Prefer checked,
  saturating, or explicit conversion behavior when the domain can exceed
  expected bounds.
- Prefer `From` and `TryFrom` over lossy `as` casts when a conversion can
  fail or silently truncate.
- Prefer bounded domain types such as `NonZero*` or validated newtypes
  when raw numbers permit invalid states.
- Review indexing and slicing as panic surfaces, not as harmless syntax.

## Secrets and serialization

- Do not assume derived traits are harmless on sensitive types.
- Review `Debug`, `Serialize`, and `Deserialize` derives on secrets,
  credentials, and tokens with extra skepticism.
- Prefer redacted `Debug` output for secret-bearing types.
- Prefer validated constructors or `serde(try_from = "...")`-style
  boundaries when deserialization must preserve invariants.
- Review whether deserialization can bypass checks that normal
  constructors enforce.

## Filesystem and process boundaries

- Review filesystem code for TOCTOU-style assumptions. A check followed
  by a later use is not necessarily a safe sequence.
- Review path handling carefully. Absolute or rooted paths can override
  an intended base path in join-like operations.
- Review unbounded input handling, file reads, and decompression paths
  for memory or resource exhaustion risk.
- Review secret comparisons and auth checks for side-channel-sensitive
  code. Constant-time comparison may be the correct primitive.

## API and boundary review

- Be strict with FFI, persistence, network, and config-loading code.
  These boundaries often turn logic bugs into security or data-loss bugs.
- Prefer narrow boundary types that validate early over permissive
  "stringly typed" entry points.
- Review whether public APIs expose partial or invalid states that only
  become dangerous once data crosses a trust boundary.
- Suggest tooling such as `cargo-geiger` when transitive `unsafe`
  matters to the risk profile.

## Review smells

- Heavy use of `as` where a fallible conversion would be clearer.
- Secret-bearing types deriving `Debug` or serde traits without an
  explicit decision.
- Filesystem code that checks and then later trusts a path or file.
- Boundary types accepting raw strings, bytes, or numbers without
  validation.
- Security-sensitive code relying on "this is safe Rust" as the main
  argument for correctness.

## Sources

- Corrode, `Pitfalls of Safe Rust`:
  <https://corrode.dev/blog/pitfalls-of-safe-rust/>
- Corrode, `Patterns for Defensive Programming in Rust`:
  <https://corrode.dev/blog/defensive-programming/>
- Corrode, `Compile-Time Invariants in Rust`:
  <https://corrode.dev/blog/compile-time-invariants/>
